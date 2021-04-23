#!/bin/bash
# Note: to list or restore files, simple cat (shell expansion is sorted)
# cat backup-name-####.backup | gpg -d - | tar -tvz
# cat backup-name-####.backup | gpg -d - | tar -xvz
# do the above with each subsequent incremental backup, but decrypt the \
# snapshot first, and use -g.  We'll add a restore feature shortly.
# This is required in order to detect which files were deleted between each
# backup, and have tar remove them for you automatically as part of the restore.
# gpg -d backup-name-####.spb > backup-name-####.sp
# cat backup-name-####.backup | gpg -d - | tar -xvzg backup-name-####.sp


# This script is based on simple concepts
# 1. start with level 0 backup, meaning initial backup.  it's index is 0
# 2. subsequent backups get a ms timestamp since 1970 as their index value.
# 3. to start over just delete home.sp, resulting in a new index 0 backup
# 4. make sure you are backing up to a new bucket or folder if starting over, so
#    that you don't get confused on which timestamped backups are 
#    relevant to your current level 0.
# 5. We support splitting backups at 4G by default, so if you wanted you could
#    copy them to a FAT32 USB drive.
#

function show_help(){
  printf "e.g. %s [-h|-?|--help] \n" "${orig_args[0]}"
  printf "\t<-p|--path backup-folder>       - the folder to backup to\n"
  printf "\t<-s|--source source-folder>     - the folder to backup\n"
  printf "\t<-n|--name>                     - the name of the backup\n"
  printf "\n"
  printf "\t[-b|--bucket s3-bucket-name]    - the s3 bucket name if you want to push to s3\n"
  printf "\t[-e|--exclude tar-exclude-file] - the tar exclude file\n"
}

function exitWith(){
  echo "$1";
  echo
  show_help
  exit 99;
}

skip_s3="true"
# Here's some example parameter handling, -d has no args, -p has an argument
while :; do
  case $1 in
    -h|-\?|--help)
      show_help    # Display a usage synopsis.
      exit
      ;;
    -b|--bucket)
      shift
      s3_bucket_name="$1"
      unset skip_s3
      ;;
    -e|--exclude)
      shift
      backup_exclude=("--exclude-from")
      backup_exclude+=("$1")
      ;;
    -p|--path)
      shift
      backup_folder="$1"
      ;;
    -s|--source)
      shift
      source_folder+=("$1")
      ;;
    -n|--name)
      shift
      backup_name="$1"
      ;;
    ?*)
      args+=($1)
      ;;
    *)
      break;
      ;;
    esac

    shift
done

[[ -d "$source_folder" ]] || { exitWith "missing source folder $source_folder"; }

function encrypt(){
#   openssl enc -aes-256-cbc -pbkdf2 -iter 1000 -pass "pass:$(pass show personal/backup)"
  gpg -r trent.gpg@trentonadams.ca --encrypt 
}

# example decrypt
#   openssl enc -d -aes-256-cbc -pass "pass:$(cat ~/.backup.cloud.pw)"
#  gpg -d

#[[ -f ~/.aws/bin/activate ]] || { exitWith "aws cli not installed";  }
#source "/home/trenta/.aws/bin/activate"

command -v split || { exitWith "split command not installed";}
command -v aws || { exitWith "aws cli not installed"; }
command -v tar || { exitWith "tar not installed"; }
[[ -d "$backup_folder" ]] || { exitWith "missing backup folder $backup_folder" ; }

[[ "function" == "$(type -t encrypt)" ]] || { exitWith "encrypt function must exist"; }
[[ ! -z "$backup_name" ]] || { exitWith "backup name empty"; }

[[ "true" == "$skip_s3" ]] || aws s3 ls "$s3_bucket_name" >/dev/null || exitWith "s3 bucket access problem?"

index=$(date +'%s')

# a previous snapshot does not exist, let's label this level 0
[[ -f "$backup_folder/${backup_name}.sp" ]] || { index=0 ; }
backup_file="$backup_folder/${backup_name}.${index}.backup"

tar -czg "$backup_folder/${backup_name}.sp" ${backup_exclude[@]} \
  "${source_folder[@]}" | encrypt > "$backup_file"

size=$(stat --printf="%s" "$backup_file")
if (($size > 3900000000)); then 
  echo "berry large file, won't fit on FAT32";
  split -b 3G "$backup_file" "$backup_file"
  rm "$backup_file"  # delete original, it's now split into multiple segments
fi

# encrypt tar snapshot to snapshot backup
cat "$backup_folder/${backup_name}.sp" | encrypt > "$backup_folder/${backup_name}.${index}.spb"

if (($size > 150000000)); then
  # TODO
  # - add step to print out how to revert the snapshot file and backup 
  #   to start over
  # - add integrity checking of tar
  # - add integrity checking of encryption by decrypting out to /dev/null
  tmp_file=$(mktemp /tmp/mail-XXXX.txt)

  echo "tar backup very large $(($size / 1000 / 1000)) Mbytes" > $tmp_file
  echo >> $tmp_file
  echo "If this is your first backup, or you expected it to be large, you may ignore this." >> $tmp_file
  echo >> $tmp_file
  echo "If you'd like to start over, delete $backup_file, and " >> $tmp_file
  echo "restore the most recent $backup_folder/${backup_name}.###.spb" >> $tmp_file
  echo "to $backup_folder/${backup_name}.sp, but remember to decrypt" >> $tmp_file
  echo "it." >> $tmp_file

  cat "${tmp_file}"
fi

# ${backup_name}.sp stays unencrypted for next round, so we don't upload it
[[ "$skip_s3" != "true" ]] && \
  aws s3 sync "$backup_folder/" s3://$s3_bucket_name/ --exclude '*.sp'
