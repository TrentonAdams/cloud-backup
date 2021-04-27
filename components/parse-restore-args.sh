function parseRestoreArgs() {
  # Here's some example parameter handling, -d has no args, -p has an argument
  while :; do
    case $1 in
    -s | --source)
      shift
      printf "backup_folder='%s'\n" "$1"
      ;;
    -r | --restore)
      shift
      printf "restore_folder+=('%s')\n" "$1"
      ;;
    -n | --name)
      shift
      printf "backup_name='%s'\n" "$1"
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
