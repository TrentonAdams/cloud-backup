function parseRestoreArgs() {
  # Here's some example parameter handling, -d has no args, -p has an argument
  while :; do
    case $1 in
    -s | --source)
      shift
      printf "export source_folder='%s';\n" "$1"
      ;;
    -d | --destination)
      shift
      printf "export destination_folder+=('%s');\n" "$1"
      ;;
    -n | --name)
      shift
      printf "export backup_name='%s';\n" "$1"
      ;;
    ?*)
      printf "export args+=('%s');\n" "$1"
      ;;
    *)
      break
      ;;
    esac

    shift
  done
}
