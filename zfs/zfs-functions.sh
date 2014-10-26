# TODO: Do proper parameter validation and return appropriate
# status codes. For example, empty strings should not be valid
# parameters.
# TODO: Discard standard error on all commands

ZFS_CMD=/sbin/zfs


# Reads the value of a ZFS propety.
rdnzl_zfs_get_property_value()
{
    ZFSFS="$1"
    ZFSPROP="$2"
    "${ZFS_CMD}" get -H -o value "$ZFSPROP" "$ZFSFS"
}

# Tests if a dataset exists
# Produces no output, caller should test $?
rdnzl_zfs_filesystem_exists()
{
    ZFS_DATASET="$1"

    "${ZFS_CMD}" list -t filesystem -H -o name "${ZFS_DATASET}" >/dev/null 2>&1
}

# Same for snapshots
rdnzl_zfs_snapshot_exists()
{
    ZFS_SNAPSHOT="$1"

    "${ZFS_CMD}" list -t snapshot -H -o name "${ZFS_SNAPSHOT}" >/dev/null 2>&1
}

# Returns the filesystem name of a path
rdnzl_zfs_filesystem_from_path()
{
    ZFS_PATH="$1"

    "${ZFS_CMD}" list -H -o name "${ZFS_PATH}"  
}

