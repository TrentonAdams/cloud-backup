#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source ./cloud-tar.sh

# these are our End To End (e2e) tests.  We verify real functionality with
# no stubs or mocks of any kind.

# this test requires you to pass in gpg_recipient, and is therefore
# skipped without it
# e.g.
# gpg_recipient=me@example.com ./test/libs/bats/bin/bats test/*.bats
@test "backup should create backup files" {
  rm -rf files/ backup/
  [[ -z "${gpg_recipient}" ]] && \
    skip "skipping real test run without gpg_recipient env var";
  # arrange
  mkdir -p files backup
  for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done
  # act
  run cloudTar backup \
    -r ${gpg_recipient} \
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

