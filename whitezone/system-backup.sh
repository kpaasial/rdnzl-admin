#!/bin/sh --

# The source must be a ZFS dataset
SOURCEDATASETS="zwhitezone/ROOT zwhitezone/DATA zwhitezone/LOCAL"

# Destination can be anything just as long as the directory exists
BACKUPDIRECTORY=/zwzbackup1/rsyncbackups/whitezone/zwhitezone

RSYNC="/usr/local/bin/rsync"

RSYNCFLAGS="-aAFHXxv --fileflags --delete --delete-excluded --force-schange"

# Check that the source dataset is available

for SOURCEDATASET in $SOURCEDATASETS; do
    if ! [ $(/sbin/zfs list -H -o name ${SOURCEDATASET} ) ]; then
        echo "Source dataset ${SOURCEDATASET} not available, can not continue."
        exit 1
    fi
done


# Check that the backup directory exists 
if ! [ -d "${BACKUPDIRECTORY}"  ]; then
    echo "Backup directory ${BACKUPDIRECTORY} does not exist, can not continue."
    exit 1
fi



for SOURCEDATASET in $SOURCEDATASETS; do

    # Create a short lived recursive snapshot of the source dataset

    SNAPNAME=$(/usr/local/bin/zfs_snapshot.py -p backup -a 1d -r ${SOURCEDATASET})

    if [ $? -ne 0 ]; then
        echo "Could not create snapshot of the source dataset, can not continue."
        exit
    fi

    SNAPNAME=$(echo ${SNAPNAME} | /usr/bin/cut -d@ -f2)

    echo "Snapshot name is ${SNAPNAME}"

    for MOUNTPOINT in $(zfs list -H -o mountpoint -r ${SOURCEDATASET} | grep -vw none); do
        echo ""
        if [ ! -d "${MOUNTPOINT}/.zfs/snapshot/${SNAPNAME}" ]; then
            echo "Source directory ${MOUNTPOINT}/.zfs/snapshot/${SNAPNAME} does not exist, can not continue."
            exit 1    
        fi

        # Flatten the source hierarchy to a single level of subdirectories under the
        # destination directory. For example: /usr/local/ -> ${BACKUPDIRECTORY}/_usr_local 
        # This avoids 'rsync --delete --one-file-system ...' from deleting the contents of deeper nested datasets on
        # the destination side
        MOUNTPOINT_FLAT=$(echo $MOUNTPOINT | sed -e 's+/+_+g')

        if [ ! -d "${BACKUPDIRECTORY}/${MOUNTPOINT_FLAT}" ]; then
            echo "Destination directory ${BACKUPDIRECTORY}/${MOUNTPOINT_FLAT} does not exist, creating it"
            mkdir "${BACKUPDIRECTORY}/${MOUNTPOINT_FLAT}"
        fi

        echo "${MOUNTPOINT}/.zfs/snapshot/${SNAPNAME}/ -> ${BACKUPDIRECTORY}/${MOUNTPOINT_FLAT}"
        ${RSYNC} ${RSYNCFLAGS} "${MOUNTPOINT}/.zfs/snapshot/${SNAPNAME}/" "${BACKUPDIRECTORY}/${MOUNTPOINT_FLAT}" || exit 1
    done

done


