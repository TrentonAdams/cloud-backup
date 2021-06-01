#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source components/parse-restore-args.sh

@test "parseRestoreArgs with -s should set backup_folder env var" {
  # we trust the output here to be env vars from parseRestoreArgs
  run parseRestoreArgs -s backup-folder
  eval "${output}"
  refute [ -z "${backup_folder}" ]
  assert [ "backup-folder" == "${backup_folder}" ]
}

@test "parseRestoreArgs with -r should set restore_folder env var" {
  # we trust the output here to be env vars from parseRestoreArgs
  run parseRestoreArgs -d restore-folder
  eval "${output}"
  refute [ -z "${restore_folder}" ]
  assert [ "restore-folder" == "${restore_folder}" ]

  run parseRestoreArgs --restore restore-folder
  eval "${output}"
  refute [ -z "${restore_folder}" ]
  assert [ "restore-folder" == "${restore_folder}" ]
}

@test "parseRestoreArgs with -n should set backup_name env var" {
  # we trust the output here to be env vars from parseRestoreArgs
  run parseRestoreArgs -n backup_name
  eval "${output}"
  refute [ -z "${backup_name}" ]
  assert [ "backup_name" == "${backup_name}" ]

  run parseRestoreArgs --name backup_name
  eval "${output}"
  refute [ -z "${backup_name}" ]
  assert [ "backup_name" == "${backup_name}" ]
}
