#!/bin/sh --


SOURCE=/data/jails/sambajail/mnt/media
DEST=/data/jails/sambajail/mnt/backup/media

EXCLUDE_FROM=rsync.exclude

RSYNC=/usr/local/bin/rsync
RSYNC_FLAGS="-avz --delete"

if [ -r ${SOURCE}/${EXCLUDE_FROM} ]; then
RSYNC_FLAGS="${RSYNC_FLAGS} --exclude=${SOURCE}/rsync.exclude"
fi

# TODO: test that both source and destination are actually mounted

if [ ! -d ${SOURCE} ]; then
    echo "Source directory $SOURCE does not exist!"
    exit 1
fi

if [ ! -d ${DEST} ]; then
    echo "Destination directory $DEST does not exist!"
    exit 1
fi


${RSYNC} ${RSYNC_FLAGS} $SOURCE/ $DEST
