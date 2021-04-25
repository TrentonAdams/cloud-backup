#!/bin/bash
# Note: to list or restore files, simple cat (shell expansion sorts files in the correct alphabetical order)
# cat backup-name-####.backup* | gpg -d - | tar -tvz
# cat backup-name-####.backup* | gpg -d - | tar -xvz
# do the above with each subsequent incremental backup, but decrypt the \
# snapshot first, and use -g.  We'll add a restore feature shortly.
# This is required in order to detect which files were deleted between each
# backup, and have tar remove them for you automatically as part of the restore.
# gpg -d backup-name-####.spb > backup-name-####.sp
# cat backup-name-####.backup* | gpg -d - | tar -xvzg backup-name-####.sp

# This script is based on simple concepts
# 1. start with level 0 backup, meaning initial backup.  it's backup_index is 0
# 2. subsequent backups get a ms timestamp since 1970 as their backup_index value.
# 3. to start over just delete home.sp, resulting in a new backup_index 0 backup
# 4. make sure you are backing up to a new bucket or folder if starting over, so
#    that you don't get confused on which timestamped backups are
#    relevant to your current level 0.
# 5. We support splitting backups at 4G by default, so if you wanted you could
#    copy them to a FAT32 USB drive.
#

source components/show-help.sh
source components/parse-args.sh
source components/backup.sh

function exitWith() {
  echo "$1"
  echo
  show_help
  exit 99
}

function encrypt() {
  # only encrypt if recipient given
  if [[ -z "${gpg_recipient}" ]]; then
    cat
  else
    gpg -r "${gpg_recipient}" --encrypt
  fi
}

function verifyRequiredCommands() {
  command -v split >/dev/null || { exitWith "split command not installed"; }
  command -v aws >/dev/null || { exitWith "aws cli not installed"; }
  command -v tar >/dev/null || { exitWith "tar not installed"; }
  command -v stat >/dev/null || { exitWith "stat not installed"; }
  command -v split >/dev/null || { exitWith "split not installed"; }
  command -v mktemp >/dev/null || { exitWith "mktemp not installed"; }
}

function cloudTar() {
  skip_s3="true"
  my_args=$(parseCommands "$@")
  eval "${my_args}"

  my_args=$(parseBackupArgs "$@")
  eval "${my_args}"

  [[ -z "${gpg_recipient}" ]] &&
    echo "WARNING your backup will not be encrypted, as no gpg recipient was specified"

  verifyArgs
  verifyRequiredCommands
  doBackup

  # ${backup_name}.sp stays unencrypted for next round, so we don't upload it
  [[ "$skip_s3" != "true" ]] &&
    aws s3 sync "${backup_folder}/" "s3://${s3_bucket_name}/" --exclude '*.sp'
}

# only run cloudTar if this script was executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cloudTar "$@"
fi
