# We have to print env vars for arguments set because BATS runs commands
# and functions in subshells, so any environment setting within a function is
# not available in a test.

function parseCommands() {
  echo "mode=unselected;"
# Here's some example parameter handling, -d has no args, -p has an argument
while :; do
  case $1 in
    backup)
      echo "mode=backup;"
      ;;
    *)
      break;
      ;;
    esac

    shift
done
}

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

# Simply verifies all arguments have passed as they should
# TODO create array of messages to display, and then exit if it's count is
#  non-zero
function verifyArgs() {
  [[ ! -z "${show_help}" ]] && { show_help; exit 1; }
  [[ ${mode} == unselected ]] && { exitWith "no selected command"; }
  [[ -d "${source_folder}" ]] || { exitWith "missing source folder ${source_folder}"; }
  [[ -d "${backup_folder}" ]] || { exitWith "missing backup folder ${backup_folder}" ; }
  [[ "function" == "$(type -t encrypt)" ]] || { exitWith "encrypt function must exist"; }
  [[ ! -z "${backup_name}" ]] || { exitWith "backup name empty"; }
  [[ "true" == "$skip_s3" ]] || aws s3 ls "${s3_bucket_name}" >/dev/null || exitWith "s3 bucket access problem?"
}
