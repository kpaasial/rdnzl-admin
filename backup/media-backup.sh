#!/bin/sh --

SOURCEDATASET=zwzmedia/DATA/media
DESTDATASET=zwzbackup/DATA/backup
DESTSUBFOLDER=media

EXCLUDE_FROM=rsync.exclude

ZFS_CMD=/sbin/zfs

RSYNC=/usr/local/bin/rsync
RSYNC_FLAGS="-avz --delete"


if ! [ $( $ZFS_CMD list -H -o name "${SOURCEDATASET}" ) ]; then
    echo "Source dataset ${SOURCEDATASET} not available, can not continue."
    exit 1
fi

if ! [ $( $ZFS_CMD list -H -o name "${DESTDATASET}" ) ]; then
    echo "Destination dataset ${DESTDATASET} not available, can not continue."
    exit 1
fi


SOURCEMNTPOINT=$( $ZFS_CMD get -H -o value mountpoint ${SOURCEDATASET})

DESTMNTPOINT=$( $ZFS_CMD get -H -o value mountpoint ${DESTDATASET})

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

echo ${RSYNC} ${RSYNC_FLAGS} ${SOURCEMNTPOINT}/ ${DESTMNTPOINT}/${DESTSUBFOLDER}
