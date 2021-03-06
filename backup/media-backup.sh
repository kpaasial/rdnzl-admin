#!/bin/sh --

set -u

. zfs-functions.sh

SOURCEDATASET=zwzmedia/DATA/media

DESTPOOL=zwzbackup

DESTDATASET="${DESTPOOL}/DATA/backup"
DESTSUBFOLDER=media

EXCLUDE_FROM=rsync.exclude


RSYNC=/usr/local/bin/rsync
RSYNC_FLAGS="-avz --delete"

if [ `id -u` -ne 0 ]; then
    echo "Please run $0 as root."
    exit 1
fi

if ! zfs_dataset_exists "${SOURCEDATASET}"; then
    echo "Source dataset ${SOURCEDATASET} not available, can not continue."
    exit 1
fi


if ! zfs_pool_exists "${DESTPOOL}"; then
    echo "Destination pool ${DESTPOOL} not available, trying to import it."   
    if ! $ZPOOL import "${DESTPOOL}"; then 
        echo "Can not import ${DESTPOOL}, exiting."
        exit 1
    fi
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

if ! ${RSYNC} ${RSYNC_FLAGS} ${SOURCEMNTPOINT}/ ${DESTMNTPOINT}/${DESTSUBFOLDER}; then
    echo "Backup failed, exiting"
    exit 1
fi



