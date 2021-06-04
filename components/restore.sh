function doRestore() {
  [[ -d "${source_folder}" ]] || { exitWith "missing source folder ${source_folder}"; }
  mkdir -p "${destination_folder}" || { exitWith "unable to create folder ${destination_folder}"; }

  for backup in ${source_folder}/${backup_name}.*.backup*; do
    echo "restoring ${backup}"
    file "${backup}"| grep PGP
    if [ $? -eq 0 ]; then
      gpg -d -o - "${backup}" | tar -C "${destination_folder}" -g /dev/null -xvz
    else
      tar -C "${destination_folder}" -g /dev/null -xvzf "${backup}"
    fi


  done
}