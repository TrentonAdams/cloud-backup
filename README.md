# Cloud TAR

Backup scripts to manage incremental backups using gnu tar's incremental snapshot capability, while supporting an s3 sync as well.

This is not ready for prime time, as I'm learning [BATS](https://github.com/sstephenson/bats) and adding a bunch of automated tests first.
                      
To back up...
1. user named "user"
2. to folder `/media/backup/cloud-tar`
3. with gpg encryption to gpg recipient `me@example.com`
4. an s3 sync to s3 bucket named user-backup-home
5. using `~/backup/tar-excludes.txt` as the tar exclusion file

```bash
~/backup/cloud-tar.sh \
  -s /home/user/ \
  -p /media/backup/cloud-tar \
  -n home \
  -r me@example.com \
  -e ~/backup/tar-excludes.txt \
  -b user-backup-home;
```

# TODO
                     
* add tests for main program
* finish parseArgs testing
* add integrity check (`tar -tvzg file.sp`)
* add restore script
* make "splitting" at 4G an option, not a requirement.