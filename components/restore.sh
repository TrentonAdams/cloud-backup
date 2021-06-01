function decrypt() {
  # only encrypt if recipient given
  gpg --pinentry-mode cancel --list-packets "${backup}" > /dev/null
  if [ $? -eq 0 ]; then
    gpg -d -o -
  else
    cat
  fi
}

function doRestore() {
  [[ -d "${source_folder}" ]] || { exitWith "missing source folder ${source_folder}"; }
  mkdir -p "${destination_folder}" || { exitWith "unable to create folder ${destination_folder}"; }

  ls -ltr "${source_folder}"
  for backup in ${source_folder}/${backup_name}.*.backup*; do
    echo "restoring ${backup}"
    cat "${backup}" | decrypt | tar -C "${destination_folder}" -g /dev/null -xvz
  done
}