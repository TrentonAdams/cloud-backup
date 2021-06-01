
function show_help(){

  printf "Backup Arguments:\n"
  printf "e.g. %s backup [-h|-?|--help] \n" "${0}"
  printf "\t<-d|--destination backup-folder>       - the folder to backup to\n"
  printf "\t<-s|--source source-folder>            - the folder to backup\n"
  printf "\t<-n|--name>                            - the name of the backup\n"
  printf "\t<-r|--recipient>                       - the gpg recipient name\n"
  printf "\n"
  printf "\t[--sub-folder sub-folder]              \n"
  printf "\t  - the sub-folder to backup to; use this if you're using the bucket-option\n"
  printf "\t    to allow backing up to a sub-folder.  This can be useful to make s3 sync\n"
  printf "\t    the entire backup folder, but send backups to a monthly folder\n"
  printf "\t[-b|--bucket s3-bucket-name]    - the s3 bucket name if you want to push to s3\n"
  printf "\t[-e|--exclude tar-exclude-file] - the tar exclude file\n"
  printf "\n\n"

  printf "Restore Arguments:\n"
  printf "e.g. %s restore [-h|-?|--help] \n" "${0}"
  printf "\t<-d|--destination restore-folder>      - the folder to restore to\n"
  printf "\t<-s|--source backup-folder>            - the folder with backups\n"
  printf "\t<-n|--name>                            - the name of the backup\n"
  printf "\n"

}
