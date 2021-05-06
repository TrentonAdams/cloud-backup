#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
source components/parse-commands.sh

@test "parseCommands with -h should set show_help env var" {
  # we trust the output here to be env vars from parseCommands
  run parseCommands -h
  eval "${output}"
  refute [ -z "${show_help}" ]
}

@test "parseCommands with no command should set mode=unselected env var" {
  # we trust the output here to be env vars from parseCommands
  run parseCommands
  eval "${output}"
  refute [ -z "${mode}" ]
  assert [ "${mode}" == "unselected" ]
}

@test "parseCommands with backup command should set mode=backup env var" {
  # we trust the output here to be env vars from parseCommands
  run parseCommands backup
  eval "${output}"
  refute [ -z "${mode}" ]
  assert [ "${mode}" == "backup" ]
}

@test "parseCommands with restore command should set mode=restore env var" {
  # we trust the output here to be env vars from parseCommands
  run parseCommands restore
  eval "${output}"
  refute [ -z "${mode}" ]
  assert [ "${mode}" == "restore" ]
}

@test "verifyArgs should fail when no command used" {
  # we trust the output here to be env vars from parseCommands
  # arrange
  run parseCommands
  eval "${output}"
  function exitWith () { echo "$1"; exit 250; }
  export -f exitWith

  # act
  run verifyArgs

  # assert
  assert_output --partial "no selected command"
  assert [ $status -eq 250 ]
}
