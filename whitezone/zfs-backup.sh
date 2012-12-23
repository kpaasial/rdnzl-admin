#!/bin/sh

BACKUPPOOL="zwzbackup1"

BACKUPDATASET="pools"

SOURCEDATASET=$1

: ${SOURCEDATASET:="zwhitezone"}

# First test that source and destination are available

if ! [ $(/sbin/zfs list -H -o name ${SOURCEDATASET} ) ]; then
    echo "Source dataset ${SOURCEDATASET} not available, can not continue."
    exit 1
fi

if ! [ $(/sbin/zpool list -H -o name ${BACKUPPOOL} ) ]; then
    echo "Backup pool ${BACKUPPOOL} not available, can not continue."
    exit 1
fi

DESTDATASET="${BACKUPPOOL}/${BACKUPDATASET}/${SOURCEDATASET}"


if ! [ $(/sbin/zfs list -H -o name ${DESTDATASET} ) ]; then
    echo "Destination dataset ${DESTDATASET} not available, can not continue."
    exit 1
fi




# Find out the last snapshot in the backup pool of the source dataset
# This will fail to find snapshots that are done separately on a child
# dataset of the source dataset.

LATESTBACKUPSNAP=$(/sbin/zfs list -t snapshot -r -H -o name \
    -S creation | grep "^${DESTDATASET}@" | \
     head -1 | cut -d@ -f2) 

# Create a short-lived recursive snapshot of the source dataset
SNAPNAME=$(/usr/local/bin/zfs_snapshot.py -p zfsbck -a 1d -r ${SOURCEDATASET})

echo "Snapshot name is ${SNAPNAME}"

# Now the magic.
# For 'zfs send' the -R flag is used to create a replication stream or
# incremental replication stream. 

# The argument for 'zfs send' is the name of the snapshot created above

# If there are previous snapshots of the source data set in the backup,
# the latest one of the is used for the -I option as the basis for the
# incremental replication stream.

# On 'zfs receive' the -d option is used and the destination filesystem is set
# to ${BACKUPPOOL}/${BACKUPDATASET} to create a full hierarchy of the source
# rooted at ${BACKUPPOOL}/${BACKUPDATASET}. 
# The -F option is used to force rollback of the backup dataset to the
# state of the latest snapshot before receiving the new snapshots.


if [ -z ${LATESTBACKUPSNAP} ]; then
    echo "No snapshots of ${SOURCEDATASET} in the backup, doing full backup"
    /sbin/zfs send -R "${SNAPNAME}" | \
        /sbin/zfs receive -F -v -d "${DESTDATASET}" 
else
    echo "Using ${LATESTBACKUPSNAP} as the basis for incremental backup"
    /sbin/zfs send -R -I "${LATESTBACKUPSNAP}" "${SNAPNAME}" | \
        /sbin/zfs receive -F -v -d "${DESTDATASET}"
fi

