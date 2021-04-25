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
  run cloudTar backup \
    -s ./files/ \
    -p backup/ \
    -n test-backup;
  assert [ -f backup/test-backup.sp ]
  assert [ -f backup/test-backup.0.spb ]
  assert [ -f backup/test-backup.0.backup ]
  function listBackup() { cat backup/test-backup.0.backup | tar -tvz; }
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
  run cloudTar backup \
    -r ${recipient} \
    -s ./files/ \
    -p backup/ \
    -n test-backup;
  function listBackup() { cat backup/test-backup.0.backup | gpg -d | tar -tvz; }
  run listBackup
  # assert
  assert [ -f backup/test-backup.sp ]
  assert [ -f backup/test-backup.0.spb ]
  assert [ -f backup/test-backup.0.backup ]
  for i in {1..10}; do
    assert_output --partial "files/file-${i}";
  done
  rm -rf files/ backup/
}

