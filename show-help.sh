
function show_help(){
  printf "e.g. %s [-h|-?|--help] \n" "${0}"
  printf "\t<-p|--path backup-folder>       - the folder to backup to\n"
  printf "\t<-s|--source source-folder>     - the folder to backup\n"
  printf "\t<-n|--name>                     - the name of the backup\n"
  printf "\n"
  printf "\t[-b|--bucket s3-bucket-name]    - the s3 bucket name if you want to push to s3\n"
  printf "\t[-e|--exclude tar-exclude-file] - the tar exclude file\n"
}