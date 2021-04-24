# Cloud TAR

Backup scripts to manage incremental backups using gnu tar's incremental snapshot capability, while supporting an s3 sync as well.

This should work for other people now.  I'm still I'm learning [BATS](https://github.com/sstephenson/bats) and adding a bunch of automated tests though to ensure everything continues working as expected as I continue to make adjustments.
    
## Usage                  
To back up...
1. user named "${USER}" from your USER environment var
2. to folder `/media/backup/cloud-tar`
3. with gpg encryption to gpg recipient `me@example.com`
4. an s3 sync to s3 bucket named user-backup-home
5. using `~/backup/tar-excludes.txt` as the tar exclusion file

So let's clone, run tests, and run a test backup.

```bash
git clone --recurse-submodules git@github.com:TrentonAdams/cloud-tar.git
cd cloud-tar/
./test/libs/bats/bin/bats test/*.bats
./cloud-tar.sh \
  -s /home/${USER} \
  -p /media/backup/cloud-tar \
  -n home \
  -r me@example.com \
  -e ~/backup/tar-excludes.txt \
  -b user-backup-home;
```

An example tar-excludes.txt follows.  Replace `username` with your `${USER}`

```text
/home/username/.config/google-chrome
/home/username/.cache
/home/username/.config/Code/Cache
/home/username/.config/Code/CacheData
```

## TODO
                     
* add tests for main program
* add integrity check (`tar -tvzg file.sp`)
* add restore script.
* add backup deletion script.
  * Possibly `ls -1 backup-dir/name.*.spb | tail -2` to get previous backup snapshot file
  * Decrypt backup snapshot file to `backup-dir/name.sp`
  * Delete files for `ls -1 backup-dir/name.*.spb | tail -1`
  * Delete files for `ls -1 backup-dir/name.*.backup* | tail -1`
  * Previous won't quite work, as we need to account for split file names.  So we need to grab the timestamp from the most recent backup file name, and then deleted wildcarded `name.*.backup*`
* make "splitting" at 4G an option, not a requirement.
* create asciinema demo.
* add argument for backup size warning
