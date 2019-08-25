#!/bin/sh


. zfs-functions.sh

HOSTNAME=$(/bin/hostname)

# Current time with seconds rounded down to 00
TIMESTAMP=$(/bin/date "+%Y-%m-%d_%R:00")

SOURCEPOOL="zwzfreebsd"

BACKUPPOOL="zwzbackup"

SOURCEDATASET="${SOURCEPOOL}/ROOT/default"

BACKUPDATASET="${BACKUPPOOL}/DATA/backup"

BACKUPSUBFOLDER="$HOSTNAME"


if [ $(id -u) -ne 0 ]; then
    echo "Please run $0 as root"
    exit 1
fi


if ! zfs_dataset_exists "${SOURCEDATASET}"; then
    echo "Source dataset ${SOURCEDATASET} not available, can not continue."
    exit 1
fi

if ! zfs_dataset_exists "${BACKUPDATASET}"; then
    echo "Backup dataset ${BACKUPDATASET} not available, can not continue."
    exit 1
fi

BACKUPPATH=$(zfs_get_mountpoint "${BACKUPDATASET}")

BACKUPPATH="${BACKUPPATH}/${BACKUPSUBFOLDER}"

BACKUPFILE=$( echo "${SOURCEDATASET}" | sed -e 's^/^_^g')
BACKUPFILE="${BACKUPFILE}@${TIMESTAMP}.gzip"


# Create a new recursive snapshot on the source dataset
if ! zfs_snapshot "${SOURCEDATASET}" "$TIMESTAMP" "1"; then
    echo "Could not create snapshot on ${SOURCEDATASET}"
    exit 1
fi


cat <<EOT
    Backing up dataset ${SOURCEDATASET}@${TIMESTAMP} into \
    ${BACKUPPATH}/${BACKUPFILE}
EOT

/sbin/zfs send -R "${SOURCEDATASET}@${TIMESTAMP}" | \
        /usr/bin/gzip -2 > "${BACKUPPATH}/${BACKUPFILE}"

