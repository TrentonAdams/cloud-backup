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
  backup_index=$(date +'%s')

  # a previous snapshot does not exist, let's label this level 0
  [[ -f "${backup_folder}/${backup_name}.sp" ]] || { backup_index=0; }
  backup_file="${backup_folder}/${backup_name}.${backup_index}.backup"

  tar -czg "${backup_folder}/${backup_name}.sp" "${backup_exclude[@]}" \
    "${source_folder[@]}" | encrypt >"$backup_file"

  size=$(stat --printf="%s" "${backup_file}")
  if (($size > 3900000000)); then
    echo "berry large file, won't fit on FAT32"
    split -b 4G "${backup_file}" "${backup_file}"
    rm "${backup_file}" # delete original, it's now split into multiple segments
  fi

  # encrypt tar snapshot to snapshot backup
  cat "${backup_folder}/${backup_name}.sp" | encrypt >"${backup_folder}/${backup_name}.${backup_index}.spb"
  notifyLargeBackup
}