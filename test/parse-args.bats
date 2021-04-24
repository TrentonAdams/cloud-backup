#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source parse-args.sh

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