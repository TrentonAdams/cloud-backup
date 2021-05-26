#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source components/show-help.sh

@test "requires show_help to show help on backup command" {
  run show_help
  # bats-exec-test is the $0 argument when testing, so we test for that.
  assert_output --partial "bats-exec-test backup"
}

@test "requires show_help to show help on -d|--destination" {
  run show_help
  assert_output --partial "-d|--destination"
}

@test "requires show_help to show help on -s|--source" {
  run show_help
  assert_output --partial "-s|--source"
}

@test "requires show_help to show help on -n|--name" {
  run show_help
  assert_output --partial "-n|--name"
}

@test "requires show_help to show help on -b|--bucket" {
  run show_help
  assert_output --partial "-b|--bucket"
}

@test "requires show_help to show help on -e|--exclude" {
  run show_help
  assert_output --partial "-e|--exclude"
}

@test "requires show_help to show help on -r|--recipient" {
  run show_help
  assert_output --partial "-r|--recipient"
}

@test "requires show_help to show help on --sub-folder" {
  run show_help
  assert_output --partial "--sub-folder"
}
