# Cloud TAR

WARNING: this project probably does not support MacOS/BSD unless you install the
appropriate GNU utilities. If you'd like it to work with default MacOS/BSD
tools, please submit a patch that detects them and uses different behaviour for
MacOS/BSD only; complete with tests. It should detect the type of tool, not the
platform.

Backup scripts to manage incremental backups using gnu tar's incremental
snapshot capability, while supporting an s3 sync as well.

See [changelog.md](changelog.md)

## Install

Download
the [latest release](https://github.com/TrentonAdams/cloud-tar/releases/latest)
tar.gz. If you just want to install directly to /usr/local/bin/, you can run the
following...

```bash
# swap the -t for -x after you've confirmed the tar listing is only putting cloud-tar in `/usr/local/bin/`

curl -s https://api.github.com/repos/TrentonAdams/cloud-tar/releases/latest \
  | jq -r '.assets[0].browser_download_url' \
  | read -r latest; curl -s -L $latest \
  | sudo tar -tvz -C /usr/local/bin
```

Alternatively clone the repo and install in /usr/local/bin.

```bash
git clone --recurse-submodules git@github.com:TrentonAdams/cloud-tar.git
cd cloud-tar/
make clean tests install
```

## Examples

### Concepts

This script is based on simple concepts. The gorey details can be found on
the [TAR Incremental Dumps Page](https://www.gnu.org/software/tar/manual/html_node/Incremental-Dumps.html)

1. Start with level 0 backup, meaning initial backup. it's backup_index is 0, in
   the form backup_name.0.backup??
2. Subsequent backups get a timestamp with number of seconds since 1970 as their
   backup_index value, in the form backup_name.1622047204.backup??
3. To start over just delete backup_name.sp, resulting in a new backup_index 0
   backup, and tar will automatically create a new level 0. Although it is best
   to just backup to a new folder when you start a new level 0. The incremental
   backups are useless if you overwrite the original level 0 anyhow.
4. Make sure you are backing up to a new bucket or folder if starting over, so
   that you don't get confused on which timestamped backups are relevant to your
   current level 0. The incremental backups are useless if you overwrite the
   original level 0 anyhow.
5. We support splitting backups at 4G by default, so if you wanted you could
   copy them to a FAT32 USB drive.

### Usage

To back up...

1. user named "${USER}" from your USER environment var
2. to folder `/media/backup/cloud-tar`
3. with gpg encryption to gpg recipient `me@example.com`
4. an s3 sync to s3 bucket named user-backup-home
5. using `~/backup/tar-excludes.txt` as the tar exclusion file

So let's clone, run tests, and run a test backup.

```bash
cloud-tar backup \
  -s /home/${USER} \
  -d /media/backup/cloud-tar \
  -n home \
  -r me@example.com \
  -e ~/backup/tar-excludes.txt \
  -b user-backup-home;
```

An example tar-excludes.txt follows. Replace `username` with your `${USER}`. Tar
exclude files differ from rsync exclude files. With tar excludes you have to use
the full path that you're backing up. With rsync excludes, it's relative to the
last folder in the path you're backing up.

```text
/home/username/.config/google-chrome
/home/username/.cache
/home/username/.config/Code/Cache
/home/username/.config/Code/CacheData
```

### Full Backup Restore Example

For now, restores are manual. We'll be adding features to manage them later on.
Here's an example of some backups, along with restore.

Let's do level 0 and two incremental backups with added files then deleted
files.

```
recipient=me@example.com
rm -rf files backup; mkdir -p files backup;
for i in {1..10}; do echo "file${i}" > "files/file-${i}"; done;
cloud-tar backup \
  -s ./files/ \
  -d backup/ \
  -r "${recipient}" \
  -n test-backup;

sleep 1;
for i in {11..15}; do echo "file${i}" > "files/file-${i}"; done;
cloud-tar backup \
  -s ./files/ \
  -d backup/ \
  -r "${recipient}" \
  -n test-backup;

sleep 1;

rm -f files/file-{9,10};
cloud-tar backup \
  -s ./files/ \
  -d backup/ \
  -r "${recipient}" \
  -n test-backup;
```

Let's take a look at what we have. From this point forward you'll have to get
this working for the timestamps your backup is currently making.

```
$ ls -ltr backup             
total 28
-rw-rw-r-- 1 trenta trenta 429 May 26 17:03 test-backup.0.spb
-rw-rw-r-- 1 trenta trenta 683 May 26 17:03 test-backup.0.backupaa
-rw-rw-r-- 1 trenta trenta 441 May 26 17:03 test-backup.1622070190.spb
-rw-rw-r-- 1 trenta trenta 610 May 26 17:03 test-backup.1622070190.backupaa
-rw-rw-r-- 1 trenta trenta 197 May 26 17:03 test-backup.sp
-rw-rw-r-- 1 trenta trenta 494 May 26 17:03 test-backup.1622070191.backupaa
-rw-rw-r-- 1 trenta trenta 435 May 26 17:03 test-backup.1622070191.spb
```

To restore we want to decrypt first, so we use gpg for that. If you didn't
use `-r recipient` there's no need for the `gpg -d`.

```
rm -rf files
cat backup/test-backup.0.spb | gpg -d > current.sp
cat backup/test-backup.0.backupaa | gpg -d | tar -g current.sp -xvz
cat backup/test-backup.1622070190.spb | gpg -d > current.sp
cat backup/test-backup.1622070190.backupaa | gpg -d | tar -g current.sp -xvz
cat backup/test-backup.1622070191.spb | gpg -d > current.sp
cat backup/test-backup.1622070191.backupaa | gpg -d | tar -g current.sp -xvz
```

Take special note that it properly deletes the files that were removed as part
of the restore process...

```
gpg info output here
./files/
./files/file-1
./files/file-10
./files/file-2
./files/file-3
./files/file-4
./files/file-5
./files/file-6
./files/file-7
./files/file-8
./files/file-9
gpg info output here
./files/
./files/file-11
./files/file-12
./files/file-13
./files/file-14
./files/file-15
gpg info output here
./files/
tar: Deleting ‘./files/file-9’
tar: Deleting ‘./files/file-10’
```

## TODO

* add integrity check (`tar -tvzg file.sp`)
* add restore script.
* add backup deletion script, where we can delete success backups as far back as
  we need, and restore the snapshot file to that point.
    * Possibly `ls -1 backup-dir/name.*.spb | tail -2` to get previous backup
      snapshot file
    * Decrypt backup snapshot file to `backup-dir/name.sp`
    * Delete files for `ls -1 backup-dir/name.*.spb | tail -1`
    * Delete files for `ls -1 backup-dir/name.*.backup* | tail -1`
    * Previous won't quite work, as we need to account for split file names. So
      we need to grab the timestamp from the most recent backup file name, and
      then deleted wildcarded `name.*.backup*`
* make "splitting" at 4G an option, not a requirement.
* create asciinema demo.
* add argument for backup size warning
