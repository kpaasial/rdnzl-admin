#!/bin/sh --


. zfs-functions.sh

SOURCEDATASET=zwzmedia/DATA/media
DESTDATASET=zwzbackup/DATA/backup
DESTSUBFOLDER=media

EXCLUDE_FROM=rsync.exclude


RSYNC=/usr/local/bin/rsync
RSYNC_FLAGS="-avz --delete"


if ! zfs_dataset_exists "${SOURCEDATASET}"; then
    echo "Source dataset ${SOURCEDATASET} not available, can not continue."
    exit 1
fi

if ! zfs_dataset_exists "${DESTDATASET}"; then
    echo "Destination dataset ${DESTDATASET} not available, can not continue."
    exit 1
fi


SOURCEMNTPOINT=$( zfs_get_mountpoint "${SOURCEDATASET}" )

if [ $? -ne 0 ]; then
    echo "Can not get mountpoint for dataset ${SOURCEDATASE}"
    exit 1
fi

DESTMNTPOINT=$( zfs_get_mountpoint "${DESTDATASET}" )

if [ $? -ne 0 ]; then
    echo "Can not get mountpoint for dataset ${DESTDATASE}"
    exit 1
fi

if [ ! -d ${SOURCEMNTPOINT} ]; then
    echo "Source directory $SOURCEMNTPOINT does not exist!"
    exit 1
fi

if [ ! -d ${DESTMNTPOINT} ]; then
    echo "Destination directory $DESTMNTPOINT does not exist!"
    exit 1
fi


if [ -r ${SOURCEMNTPOINT}/${EXCLUDE_FROM} ]; then
RSYNC_FLAGS="${RSYNC_FLAGS} --exclude=${SOURCEMNTPOINT}/${EXCLUDE_FROM}"
fi

${RSYNC} ${RSYNC_FLAGS} ${SOURCEMNTPOINT}/ ${DESTMNTPOINT}/${DESTSUBFOLDER}
