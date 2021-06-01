# We have to print env vars for arguments set because BATS runs commands
# and functions in subshells, so any environment setting within a function is
# not available in a test.

function parseCommands() {
  echo "mode=unselected;"
while :; do
  case $1 in
    -h | -\? | --help)
      echo "show_help=true"
      ;;
    backup)
      echo "mode=backup;"
      ;;
    restore)
      echo "mode=restore;"
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
  [[ "function" == "$(type -t encrypt)" ]] || { exitWith "encrypt function must exist"; }
  [[ ! -z "${backup_name}" ]] || { exitWith "backup name empty"; }
  [[ "true" == "$skip_s3" ]] || aws s3 ls "${s3_bucket_name}" >/dev/null || exitWith "s3 bucket access problem?"
  validateSubFolder;
}
