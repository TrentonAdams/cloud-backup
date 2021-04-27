#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source components/parse-restore-args.sh

@test "parseBackupArgs with -p should set backup_folder env var" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseRestoreArgs -p backup-folder
  eval "${output}"
  refute [ -z "${backup_folder}" ]
  assert [ "backup-folder" == "${backup_folder}" ]
}
