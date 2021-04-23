# Cloud TAR

Backup scripts to manage incremental backups using gnu tar's incremental
snapshot capability, while supporting an s3 sync as well.


# TODO

* add integrity check (`tar -tvzg file.sp`)
* add restore script
* make "splitting" at 4G an option, not a requirement.