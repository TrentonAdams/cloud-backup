function doRestore() {
  [[ -d "${source_folder}" ]] || { exitWith "missing source folder ${source_folder}"; }
  mkdir -p "${destination_folder}" || { exitWith "unable to create folder ${destination_folder}"; }

  ls -ltr "${source_folder}"
  for backup in ${source_folder}/${backup_name}.*.backup*; do
    echo "restoring ${backup}"
    tar -C "${destination_folder}" -g /dev/null -xvzf "${backup}"
  done
}