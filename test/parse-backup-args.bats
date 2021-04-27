#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source components/parse-backup-args.sh

@test "parseBackupArgs with -b should set s3_bucket_name env var" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseBackupArgs -b bucket-name
  eval "${output}"
  refute [ -z "${s3_bucket_name}" ]
  assert [ "bucket-name" == "${s3_bucket_name}" ]
}

@test "parseBackupArgs with -b should unset skip_s3 env var" {
  # we trust the output here to be env vars from parseBackupArgs
  skip_s3=true
  run parseBackupArgs -b bucket-name
  eval "${output}"
  assert [ -z "${skip_s3}" ]
}

@test "parseBackupArgs with -e should set backup_exclude env array" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseBackupArgs -e excludes.txt
  eval "${output}"
  refute [ -z "${backup_exclude}" ]
  assert [ 2 -eq "${#backup_exclude[@]}" ]
  assert [ "--exclude-from" == "${backup_exclude[0]}" ]
  assert [ "excludes.txt" == "${backup_exclude[1]}" ]
}

@test "parseBackupArgs with -p should set backup_folder env var" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseBackupArgs -p backup-folder
  eval "${output}"
  refute [ -z "${backup_folder}" ]
  assert [ "backup-folder" == "${backup_folder}" ]
}

@test "parseBackupArgs with -s should set source_folder env var" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseBackupArgs -s source-folder -s source-folder2
  eval "${output}"
  refute [ -z "${source_folder}" ]
  assert [ 2 -eq "${#source_folder[@]}" ]
  assert [ "source-folder" == "${source_folder[0]}" ]
  assert [ "source-folder2" == "${source_folder[1]}" ]
}

@test "parseBackupArgs with -r should set gpg_recipient env var" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseBackupArgs -r me@example.com
  eval "${output}"
  refute [ -z "${gpg_recipient}" ]
  assert [ "me@example.com" == "${gpg_recipient}" ]
}

@test "parseBackupArgs with other args should set args array" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseBackupArgs -k -l
  eval "${output}"
  refute [ -z "${args}" ]
  assert [ 2 -eq "${#args[@]}" ]
  assert [ "-k" == "${args[0]}" ]
  assert [ "-l" == "${args[1]}" ]
}
