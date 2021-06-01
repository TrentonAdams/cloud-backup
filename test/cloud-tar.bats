#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source ./cloud-tar.sh

# these are our End To End (e2e) tests.  We verify real functionality with
# no stubs or mocks of any kind.

@test "backup should create backup files" {
  rm -rf files/ backup/
  # arrange
  mkdir -p files backup
  for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done
  # act
  export source_folder=./files/
  export destination_folder=backup/
  export backup_name=test-backup
  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;
#  assert [ ${status} -eq 0 ]
  assert [ -f backup/test-backup.sp ]
  assert [ -f backup/test-backup.0.spb ]
  assert [ -f backup/test-backup.0.backupaa ]
  function listBackup() { cat backup/test-backup.0.backupaa | tar -tvz; }
  run listBackup
  # assert
  for i in {1..10}; do
    assert_output --partial "files/file-${i}";
  done
  rm -rf files/ backup/
}

@test "backup should create encrypted backup files" {
  rm -rf files/ backup/
  [[ -z "${recipient}" ]] && \
    skip "skipping real test run without recipient env var";
  # arrange
  mkdir -p files backup
  for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done
  # act
  export source_folder=./files/
  export destination_folder=backup/
  export backup_name=test-backup
  export gpg_recipients=("${recipient}")
  run doBackup \
    -r "${recipient}" \
    -s ./files/ \
    -d backup/ \
    -n test-backup;
  # assert

  assert [ -d backup ]
  assert [ -f backup/test-backup.sp ]
  assert [ -f backup/test-backup.0.spb ]
  assert [ -f backup/test-backup.0.backupaa ]
  refute_output --partial "WARNING your backup will not be encrypted, as no gpg recipient was specified"

  function listBackup() { cat backup/test-backup.0.backupaa| gpg -d -o - | tar -tvz; }
  run listBackup
  for i in {1..10}; do
    assert_output --partial "files/file-${i}";
  done
  rm -rf files/ backup/
}

@test "backup should include incrementally added files" {
  rm -rf files/ backup/
  # arrange
  mkdir -p files backup
  for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done
  # act
  export source_folder=./files/
  export destination_folder=backup/
  export backup_name=test-backup
  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;
  assert [ -f backup/test-backup.sp ]
  assert [ -f backup/test-backup.0.spb ]
  assert [ -f backup/test-backup.0.backupaa ]

  touch "files/file-11"
  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;
  assert [ $(ls -1 ./backup/test-backup.*.backupaa | wc -l) -eq 2 ]

  # assert
  # most recent backup should have file-11
  function listBackup() { cat $(ls -1 backup/test-backup.*.backupaa | tail -1) | tar -tvz; }
  run listBackup
  assert_output --partial "files/file-11";
  refute_output --partial "files/file-10";
  rm -rf files/ backup/
}

# This one is a bit unwieldly.  Basically it goes like this...
# create files
# backup
# delete a file
# backup
# delete another file
# backup
# restore level 0
# restore next backup and check proper files exist
# restore next backup and check proper file was deleted
# restore final backup and check proper file was deleted
#
# Additionally, this provides a framework for creating an automatic restore
# feature.  We only need to implement folder based restores, where we assume
# there's a level 0, and a succession of backups based off that level 0, in the
# backup folder.

@test "backup should support deleting files" {
  rm -rf files/ backup/
  # arrange
  mkdir -p files backup
  for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done
  # act
  export source_folder=./files/
  export destination_folder=backup/
  export backup_name=test-backup
  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;

  rm -f "files/file-10"
  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;
  assert [ $(ls -1 ./backup/test-backup.*.backupaa | wc -l) -eq 2 ]

  # ensure the ms timestamp gets updated.  If we go too fast, sometimes
  # the backup index numbers will be the same.
  sleep 1

  rm -f "files/file-9"
  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;
  assert [ $(ls -1 ./backup/test-backup.*.backupaa | wc -l) -eq 3 ]
  ls -ltr backup

  # assert
  rm -rf files/
  function testLevel0Backup() { tar -xvzf backup/test-backup.0.backupaa; }
  run testLevel0Backup

  for i in {1..10}; do
    assert_output --regexp "\.\/files\/file-${i}";
  done


  function testIncrementalDelete() {
    cat $(ls -1 backup/test-backup.*.backupaa | tail -2 | head -1) | \
    tar -xvzg /dev/null;
  }
  # most previous backup should have file-10 listed as deleted
  run testIncrementalDelete

  assert_output --regexp "Deleting.*file-10";

  unset testIncrementalDelete
  function testIncrementalDelete() {
    cat $(ls -1 backup/test-backup.*.backupaa | tail -1) | \
    tar -xvzg /dev/null;
  }
  # most recent backup should have file-9 listed as deleted
  run testIncrementalDelete

  assert_output --regexp "Deleting.*file-9";
  rm -rf files/ backup/
}

@test "encrypt should support one recipient" {
  rm -f encrypted.txt decrypted.txt
  [[ -z "${recipient}" ]] && \
    skip "skipping real test run without recipient env var";
  export gpg_recipients=("${recipient}")
  function testEncrypt() { echo "hello" | encrypt > encrypted.txt; }
  # act
  run testEncrypt

  # assert
  function testDecrypt() { gpg -d -o - encrypted.txt 2>/dev/null; }
  run testDecrypt
  assert_output "hello"

  # cleanup
  rm -f encrypted.txt decrypted.txt
  unset gpg_recipients
}

@test "backup should create sub-folder in backup folder" {
  rm -rf files/ backup/
  # arrange
  mkdir -p files backup/sub-folder
  for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done
  # act
  export source_folder=./files/
  export destination_folder=backup/
  export backup_name=test-backup
  export backup_sub_folder=sub-folder
  run doBackup \
    -s ./files/ \
    -d backup/ \
    --sub-folder sub-folder \
    -n test-backup;
  assert [ -d backup/sub-folder ]
#  assert [ ${status} -eq 0 ]
  assert [ -f backup/sub-folder/test-backup.sp ]
  assert [ -f backup/sub-folder/test-backup.0.spb ]
  assert [ -f backup/sub-folder/test-backup.0.backupaa ]
  function listBackup() { cat backup/sub-folder/test-backup.0.backupaa | tar -tvz; }
  run listBackup
  # assert
  for i in {1..10}; do
    assert_output --partial "files/file-${i}";
  done
  rm -rf files/ backup/
}
# TODO add gpg argument support in addition to -r

@test "restore should support one backup file" {
  # arrange
  mkdir -p files backup
  for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done
  # act
  export source_folder=./files/
  export destination_folder=backup/
  export backup_name=test-backup
  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;

  assert [ -f ./backup/test-backup.*.backupaa ]

  run cloudTar restore \
    -s backup \
    -d restore \
    -n test-backup;
#  assert [ -d restore ];
  for i in {1..10}; do
    assert_output --partial "./files/file-${i}";
  done

  rm -rf backup restore files
}

@test "restore should support gpg" {
  [[ -z "${recipient}" ]] && \
    skip "skipping real test run without recipient env var";
    
  # arrange
  mkdir -p files backup
  for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done
  
  # act
  export source_folder=./files/
  export destination_folder=backup/
  export backup_name=test-backup
  export gpg_recipients=("${recipient}")

  run doBackup

  assert [ -f ./backup/test-backup.*.backupaa ]
  unset source_folder destination_folder backup_name gpg_recipients
#  unset destination_folder
  run cloudTar restore \
    -s backup \
    -d restore \
    -n test-backup;
  ls -ltr
#  assert_output --partial "Hello"
  assert [ -d restore ];
  for i in {1..10}; do
    assert_output --partial "./files/file-${i}";
  done

  rm -rf backup restore files
}

@test "restore should support multiple backup files" {
  rm -rf backup restore files
  # arrange
  mkdir -p files backup
  for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done
  # act
  export source_folder=./files/
  export destination_folder=backup/
  export backup_name=test-backup

  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;

  assert [ -f ./backup/test-backup.*.backupaa ]

  rm -f "files/file-10"
  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;
  assert [ $(ls -1 ./backup/test-backup.*.backupaa | wc -l) -eq 2 ]

  rm -f "files/file-9"
  run doBackup \
    -s ./files/ \
    -d backup/ \
    -n test-backup;
  assert [ $(ls -1 ./backup/test-backup.*.backupaa | wc -l) -eq 3 ]

  # assert
  unset source_folder destination_folder backup_name gpg_recipients
  run cloudTar restore \
    -s backup \
    -d restore \
    -n test-backup;
  assert [ -d restore ];

  for i in {1..10}; do
    assert_output --regexp "\.\/files\/file-${i}";
  done
  assert_output --regexp "Deleting.*file-10";
  assert_output --regexp "Deleting.*file-9";
  rm -rf backup restore files
}
