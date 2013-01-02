#!/bin/sh


SOURCEPOOL="zwhitezone"

BACKUPPOOL="zbackup"

BACKUPDATASET="pools"


# parse options

while getopts F o
do
    case "$o" in
    F) FULLMODE=y;;
    esac
done

shift $((OPTIND-1))

SOURCEDATASET=$1

: ${SOURCEDATASET:="zwhitezone"}

# First test that source and destination are available

if ! [  $(/sbin/zfs list -H -o name "${SOURCEDATASET}" ) ]; then
    echo "Source dataset ${SOURCEDATASET} not available, can not continue."
    exit 1
fi

if ! [ $(/sbin/zpool list -H -o name "${BACKUPPOOL}" ) ]; then
    echo "Backup pool ${BACKUPPOOL} not available, can not continue."
    exit 1
fi

DESTDATASET="${BACKUPPOOL}/${BACKUPDATASET}/${SOURCEDATASET}"

echo "DESTDATASET: ${DESTDATASET}"


# TODO: deduce this automatically from the source dataset.
BACKUPROOT="${BACKUPPOOL}/${BACKUPDATASET}/${SOURCEPOOL}"


echo "BACKUPROOT: ${BACKUPROOT}"


if ! [ $(/sbin/zfs list -H -o name "${DESTDATASET}" ) ]; then
    echo "Destination dataset ${DESTDATASET} not available, can not continue."
    exit 1
fi


# Find the last snapshot in source dataset
# If there are no snapshots do nothing

LATESTSOURCESNAP=$(/sbin/zfs list -t snapshot -r -H -o name -S creation | \
    grep "^${SOURCEDATASET}@" | head -1 | cut -d@ -f2) 

if [ -z "${LATESTSOURCESNAP}" ]; then
    echo "No snapshots in the source dataset, can not continue."
    exit 1
fi


echo "Latest snapshot of the source dataset ${SOURCEDATASET} is ${LATESTSOURCESNAP}"



# Find the last snapshot in the backup pool of the source dataset.

LATESTBACKUPSNAP=$(/sbin/zfs list -t snapshot -r -H -o name -S creation | \
    grep "^${DESTDATASET}@" | head -1 | cut -d@ -f2) 


echo "Latest snapshot of the source dataset ${SOURCEDATASET} in the backup is ${LATESTBACKUPSNAP}"


# Get the creation times as seconds from the epoch.


SOURCESNAPCREATION=$(/sbin/zfs get -p -H -o value creation "${SOURCEDATASET}@${LATESTSOURCESNAP}")

echo "SOURCESNAPCREATION: $SOURCESNAPCREATION"


if [ -n "${LATESTBACKUPSNAP}" ]; then
    BACKUPSNAPCREATION=$(/sbin/zfs get -p -H -o value creation "${DESTDATASET}@${LATESTBACKUPSNAP}")
else
    # No snapshots of the source dataset. All source snapshots are automatically newer than
    # backup.
    BACKUPSNAPCREATION=0
fi

echo "BACKUPSNAPCREATION: $BACKUPSNAPCREATION"

# Test if the snapshots are the same. If they are do nothing.

if [ "${SOURCESNAPCREATION}" -le "${BACKUPSNAPCREATION}" ]; then
    echo "The latest snapshot in the source dataset is older or as old as the"
    echo "latest snapshot of the same dataset in the backup."
    echo "Can not continue."
    exit 1
fi



# Now the magic.
# For 'zfs send' the -R flag is used to create a replication stream or
# incremental replication stream if -I flag is used. 

# The argument for 'zfs send' is the name of the last snapshot in the
# source dataset. It must be newer than the last snapshot in the
# backup.

# If there are previous snapshots of the source data set in the backup,
# the latest one of them is used for the -I option as the basis for the
# incremental replication stream.

# On 'zfs receive' the -d option is used and the destination filesystem is set
# to ${BACKUPPOOL}/${BACKUPDATASET} to create a full hierarchy of the source
# rooted at ${BACKUPPOOL}/${BACKUPDATASET}. 


if [ -z ${LATESTBACKUPSNAP} ];  then
    echo "No snapshots of ${SOURCEDATASET} in the backup, doing full backup"
    /sbin/zfs send -R "${SOURCEDATASET}@${LATESTSOURCESNAP}" | \
        /sbin/zfs receive -F -v -d "${BACKUPROOT}" 
else
    echo "Using ${LATESTBACKUPSNAP} as the incremental source snapshot."
    echo "using ${LATESTSOURCESNAP} as the last snapshot."
    /sbin/zfs send -R -I "${LATESTBACKUPSNAP}" "${SOURCEDATASET}@${LATESTSOURCESNAP}" | \
        /sbin/zfs receive -F -v -d "${BACKUPROOT}"
fi

