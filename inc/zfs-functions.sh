# sh(1) functions for handling ZFS pools and datasets

ZPOOL=/sbin/zpool
ZFS=/sbin/zfs


# Check if a dataset exists in the currently running system
zfs_pool_exists() {
    POOL=$1

    $ZPOOL get -H -o value guid "${POOL}" >/dev/null 2>&1
}

# Check if a dataset exists in the currently running system
zfs_dataset_exists() {
    DATASET=$1

    $ZFS get -H -o value name "${DATASET}" >/dev/null 2>&1 
}

# Get mountpoint of a dataset. 
zfs_get_mountpoint() {
    DATASET=$1

    MOUNTPOINT=$( $ZFS get -H -o value mountpoint "${DATASET}" 2>/dev/null)

    if [ $? -ne 0 ]; then
        return 1
    else
        echo "${MOUNTPOINT}"
        return 0
    fi
    
 
}

