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

@test "parseBackupArgs with -d should set destination_folder env var" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseBackupArgs -d backup-folder
  eval "${output}"
  refute [ -z "${destination_folder}" ]
  assert [ "backup-folder" == "${destination_folder}" ]
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

@test "parseBackupArgs with --sub-folder should set backup_sub_folder env var" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseBackupArgs --sub-folder sub-folder
  eval "${output}"
  refute [ -z "${backup_sub_folder}" ]
  assert [ "sub-folder" == "${backup_sub_folder}" ]
}

@test "parseBackupArgs with -r should set gpg_recipients env var with one gpg_recipients" {
  # we trust the output here to be env vars from parseBackupArgs
  run parseBackupArgs -r me@example.com -r too@example.com
  eval "${output}"
  refute [ -z "${gpg_recipients}" ]
  assert [ "${#gpg_recipients[@]}" -eq "2" ]
  assert [ "me@example.com" == "${gpg_recipients[0]}" ]
  assert [ "too@example.com" == "${gpg_recipients[1]}" ]
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

@test "validateSubFolder should accept 'sub-folder'" {
  # we trust the output here to be env vars from parseCommands
  # arrange
  run parseBackupArgs --sub-folder sub-folder
  eval "${output}"
  function exitWith () { echo "$1"; exit 250; }
  export -f exitWith

  # act
  run validateSubFolder

  # assert
  assert_output ''
  assert [ $status -eq 0 ]
}

@test "validateSubFolder should not accept '/' prefix with '/sub-folder'" {
  # we trust the output here to be env vars from parseCommands
  # arrange
  run parseBackupArgs --sub-folder '/sub-folder'
  eval "${output}"
  function exitWith () { echo "$1"; exit 250; }
  export -f exitWith

  # act
  run validateSubFolder

  # assert
  assert_output --regexp "sub-folder.*start.*'/'"
  assert [ $status -eq 250 ]
}

@test "validateSubFolder should not accept '/' suffix with 'sub-folder/'" {
  # we trust the output here to be env vars from parseCommands
  # arrange
  run parseBackupArgs --sub-folder 'sub-folder/'
  eval "${output}"
  function exitWith () { echo "$1"; exit 250; }
  export -f exitWith

  # act
  run validateSubFolder

  # assert
  assert_output --regexp "sub-folder.*end.*'/'"
  assert [ $status -eq 250 ]
}

@test "validateSubFolder should accept multiple sub-folders with 'sub-folder/another'" {
  # we trust the output here to be env vars from parseCommands
  # arrange
  run parseBackupArgs --sub-folder 'sub-folder/another'
  eval "${output}"
  function exitWith () { echo "$1"; exit 250; }
  export -f exitWith

  # act
  run validateSubFolder

  # assert
  assert_output ''
  assert [ $status -eq 0 ]
}

@test "support tar --no-check-device" {
  # we trust the output here to be env vars from parseCommands
  # arrange
  run parseBackupArgs --no-check-device
  eval "${output}"

  refute [ -z "${tar_args}" ]
  assert [ 1 -eq "${#tar_args[@]}" ]
  assert [ "--no-check-device" == "${tar_args[0]}" ]
}