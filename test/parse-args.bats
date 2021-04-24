#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source components/parse-args.sh

@test "parseArgs with -h should set show_help env var" {
  # we trust the output here to be env vars from parseArgs
  run parseArgs -h
  eval "${output}"
  refute [ -z "${show_help}" ]
}

@test "parseArgs with -b should set s3_bucket_name env var" {
  # we trust the output here to be env vars from parseArgs
  run parseArgs -b bucket-name
  eval "${output}"
  refute [ -z "${s3_bucket_name}" ]
  assert [ "bucket-name" == "${s3_bucket_name}" ]
}

@test "parseArgs with -b should unset skip_s3 env var" {
  # we trust the output here to be env vars from parseArgs
  skip_s3=true
  run parseArgs -b bucket-name
  eval "${output}"
  assert [ -z "${skip_s3}" ]
}

@test "parseArgs with -e should set backup_exclude env array" {
  # we trust the output here to be env vars from parseArgs
  run parseArgs -e excludes.txt
  eval "${output}"
  refute [ -z "${backup_exclude}" ]
  assert [ 2 -eq "${#backup_exclude[@]}" ]
  assert [ "--exclude-from" == "${backup_exclude[0]}" ]
  assert [ "excludes.txt" == "${backup_exclude[1]}" ]
}

@test "parseArgs with -p should set backup_folder env var" {
  # we trust the output here to be env vars from parseArgs
  run parseArgs -p backup-folder
  eval "${output}"
  refute [ -z "${backup_folder}" ]
  assert [ "backup-folder" == "${backup_folder}" ]
}

@test "parseArgs with -s should set source_folder env var" {
  # we trust the output here to be env vars from parseArgs
  run parseArgs -s source-folder -s source-folder2
  eval "${output}"
  refute [ -z "${source_folder}" ]
  assert [ 2 -eq "${#source_folder[@]}" ]
  assert [ "source-folder" == "${source_folder[0]}" ]
  assert [ "source-folder2" == "${source_folder[1]}" ]
}

@test "parseArgs with -r should set gpg_recipient env var" {
  # we trust the output here to be env vars from parseArgs
  run parseArgs -r me@example.com
  eval "${output}"
  refute [ -z "${gpg_recipient}" ]
  assert [ "me@example.com" == "${gpg_recipient}" ]
}

@test "parseArgs with other args should set args array" {
  # we trust the output here to be env vars from parseArgs
  run parseArgs -k -l
  eval "${output}"
  refute [ -z "${args}" ]
  assert [ 2 -eq "${#args[@]}" ]
  assert [ "-k" == "${args[0]}" ]
  assert [ "-l" == "${args[1]}" ]
}
