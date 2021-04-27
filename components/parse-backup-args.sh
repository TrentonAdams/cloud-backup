function parseBackupArgs() {
# Here's some example parameter handling, -d has no args, -p has an argument
while :; do
  case $1 in
    -h|-\?|--help)
      echo "show_help=true"
      ;;
    -b|--bucket)
      shift
      printf "s3_bucket_name='%s'\n" "$1"
      echo "unset skip_s3"
      ;;
    -e|--exclude)
      shift
      echo "backup_exclude=('--exclude-from')"
      printf "backup_exclude+=('%s')\n" "$1"
      ;;
    -p|--path)
      shift
      printf "backup_folder='%s'\n" "$1"
      ;;
    -s|--source)
      shift
      printf "source_folder+=('%s')\n" "$1"
      ;;
    -n|--name)
      shift
      printf "backup_name='%s'\n" "$1"
      ;;
    -r|--recipient)
      shift
      printf "gpg_recipient='%s'\n" "$1"
      ;;
    ?*)
      printf "args+=('%s')\n" "$1"
      ;;
    *)
      break;
      ;;
    esac

    shift
done
}

