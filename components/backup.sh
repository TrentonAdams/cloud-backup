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
    echo "restore the most recent ${destination_folder}/${backup_name}.###.spb" >>$tmp_file
    echo "to ${destination_folder}/${backup_name}.sp, but remember to decrypt" >>$tmp_file
    echo "it." >>$tmp_file

    cat "${tmp_file}"
  fi
}

function encrypt() {
  # only encrypt if recipient given
  if [[ -z "${gpg_recipients}" ]]; then
    cat
  else
    recipients=();
    for email in "${gpg_recipients[@]}"; do recipients+=(-r "${email}"); done
    gpg "${recipients[@]}" --encrypt
  fi
}

function doBackup() {
  [[ -d "${source_folder}" ]] || { exitWith "missing source folder ${source_folder}"; }
  [[ -d "${destination_folder}" ]] || { exitWith "missing backup folder ${destination_folder}" ; }

  backup_index=$(date +'%s%3N')
  local local_destination_folder=${destination_folder}
  [[ -z "${backup_sub_folder}" ]] || local_destination_folder="${destination_folder}/${backup_sub_folder}"

  # a previous snapshot does not exist, let's label this level 0
  [[ -f "${local_destination_folder}/${backup_name}.sp" ]] || { backup_index=0; }
  backup_file="${local_destination_folder}/${backup_name}.${backup_index}.backup"

  tar -czg "${local_destination_folder}/${backup_name}.sp" "${tar_args[@]}" \
    "${backup_exclude[@]}" \
    "${source_folder[@]}" | encrypt | \
    split -b 4G - "${backup_file}"

  # encrypt tar snapshot to snapshot backup
  cat "${local_destination_folder}/${backup_name}.sp" | encrypt >"${local_destination_folder}/${backup_name}.${backup_index}.spb"
}