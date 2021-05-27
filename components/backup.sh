function notifyLargeBackup() {
  # 150MB backup size or higher is large.
  if (($size > 150000000)); then
    # TODO
    # - add step to print out how to revert the snapshot file and backup
    #   to start over
    # - add integrity checking of tar
    # - add integrity checking of encryption by decrypting out to /dev/null
    tmp_file=$(mktemp /tmp/mail-XXXX.txt)

    echo "tar backup very large $(($size / 1000 / 1000)) Mbytes" >$tmp_file
    echo >>$tmp_file
    echo "If this is your first backup, or you expected it to be large, you may ignore this." >>$tmp_file
    echo >>$tmp_file
    echo "If you'd like to start over, delete ${backup_file}, and " >>$tmp_file
    echo "restore the most recent ${backup_folder}/${backup_name}.###.spb" >>$tmp_file
    echo "to ${backup_folder}/${backup_name}.sp, but remember to decrypt" >>$tmp_file
    echo "it." >>$tmp_file

    cat "${tmp_file}"
  fi
}

function doBackup() {
  backup_index=$(date +'%s%3N')
  local local_backup_folder=${backup_folder}
  [[ -z "${backup_sub_folder}" ]] || local_backup_folder="${backup_folder}/${backup_sub_folder}"

  # a previous snapshot does not exist, let's label this level 0
  [[ -f "${local_backup_folder}/${backup_name}.sp" ]] || { backup_index=0; }
  backup_file="${local_backup_folder}/${backup_name}.${backup_index}.backup"

  tar -czg "${local_backup_folder}/${backup_name}.sp" "${backup_exclude[@]}" \
    "${source_folder[@]}" | encrypt | \
    split -b 4G - "${backup_file}"

  # encrypt tar snapshot to snapshot backup
  cat "${local_backup_folder}/${backup_name}.sp" | encrypt >"${local_backup_folder}/${backup_name}.${backup_index}.spb"
}