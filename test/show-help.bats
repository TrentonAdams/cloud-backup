#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source components/show-help.sh

@test "requires show_help to show -p|--path" {
  run show_help
  assert_output --partial "-p|--path"
}

@test "requires show_help to show -s|--source" {
  run show_help
  assert_output --partial "-s|--source"
}

@test "requires show_help to show -n|--name" {
  run show_help
  assert_output --partial "-n|--name"
}

@test "requires show_help to show -b|--bucket" {
  run show_help
  assert_output --partial "-b|--bucket"
}

@test "requires show_help to show -e|--exclude" {
  run show_help
  assert_output --partial "-e|--exclude"
}

@test "requires show_help to show -r|--recipient" {
  run show_help
  assert_output --partial "-r|--recipient"
}
