function parseBackupArgs() {
  # Here's some example parameter handling, -d has no args, -p has an argument
  printf "gpg_recipients=();"
  while :; do
    case $1 in
    -b | --bucket)
      shift
      printf "s3_bucket_name='%s'\n" "$1"
      echo "unset skip_s3"
      ;;
    -e | --exclude)
      shift
      echo "backup_exclude=('--exclude-from')"
      printf "backup_exclude+=('%s')\n" "$1"
      ;;
    -d | --destination)
      shift
      printf "destination_folder='%s'\n" "$1"
      ;;
    -s | --source)
      shift
      printf "source_folder+=('%s')\n" "$1"
      ;;
    --sub-folder)
      shift
      printf "backup_sub_folder='%s'\n" "$1"
      ;;
    -n | --name)
      shift
      printf "backup_name='%s'\n" "$1"
      ;;
    -r | --recipient)
      shift
      printf "gpg_recipients+=('%s')\n" "$1"
      ;;
    ?*)
      printf "args+=('%s')\n" "$1"
      ;;
    *)
      break
      ;;
    esac

    shift
  done
}


function validateSubFolder() {
#  echo "backup_sub_folder: ${backup_sub_folder}"

  if [[ ! -z "${backup_sub_folder}" ]]; then
    [[ "${backup_sub_folder}" == /* ]] && { exitWith "sub-folder must not start with a '/'"; }
    [[ "${backup_sub_folder}" == */ ]] && { exitWith "sub-folder must not end with a '/'"; }
    true;
  fi;

}
