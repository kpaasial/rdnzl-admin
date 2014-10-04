#!/bin/sh


# Update the build jail with
# 'make installworld' etc. and record the installed svnrevision
# with both ZFS user properties and a snapshot @SVNREVISION. 


# TODO: Remove debug prints. Add proper notices where appropriate. 

usage()
{
    echo "Usage: $0 buildjail" 
    exit 0   
}

PREFIX="@@PREFIX@@"
SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/rdnzl-zfs-functions.sh"
. "${SHARE_RDNZL}/rdnzl-svn-functions.sh"
. "${SHARE_RDNZL}/rdnzl-jail-functions.sh"
. "${PREFIX}/etc/rdnzl-admin/sysupdate-setup.rc"



# SVNBRANCH is a fixed property and can not be changed.
# Only SVNREVISION gets updated
 
: ${BUILDJAIL:="$1"}

# Buildjail is a required argument, there is no reasonable default.
if test -z "${BUILDJAIL}"; then
    usage
fi


# Build jail filesystems
BUILDJAIL_FS="${JAIL_BASEFS}/${BUILDJAIL}"
BUILDJAILSRC_FS="${BUILDJAIL_FS}/src"
BUILDJAILOBJ_FS="${BUILDJAIL_FS}/obj"



# Sanity checks
if ! rdnzl_zfs_filesystem_exists "${BUILDJAIL_FS}"; then
    echo "No such buildjail filesystem ${BUILDJAIL_FS}"
    exit 1
fi

if ! rdnzl_zfs_filesystem_exists "${BUILDJAILSRC_FS}"; then
    echo "No such buildjail src filesystem ${BUILDJAILSRC_FS}"
    exit 1
fi

if ! rdnzl_zfs_filesystem_exists "${BUILDJAILOBJ_FS}"; then
    echo "No such buildjail src filesystem ${BUILDJAILOBJ_FS}"
    exit 1
fi


SRC_SVNREVISION=$(rdnzl_zfs_get_property_value "${BUILDJAILSRC_FS}" "${SVNREVISIONPROP}") || \
    { echo "Can not read SVNREVISION from filesystem ${BUILDJAILSRC_FS}"; exit 1;}

#SRC_SVNBRANCH=$(rdnzl_zfs_get_property_value "${BUILDJAILSRC_FS}" "${SVNBRANCHPROP}") || \
#    { echo "Can not read SVNBRANCH from filesystem ${BUILDJAILSRC_FS}"; exit 1;}

OBJ_SVNREVISION=$(rdnzl_zfs_get_property_value "${BUILDJAILOBJ_FS}" "${SVNREVISIONPROP}") || \
    { echo "Can not read SVNREVISION from filesystem ${BUILDJAILOBJ_FS}"; exit 1;}

#OBJ_SVNBRANCH=$(rdnzl_zfs_get_property_value "${BUILDJAILOBJ_FS}" "${SVNBRANCHPROP}") || \
#    { echo "Can not read SVNBRANCH from filesystem ${BUILDJAILOBJ_FS}"; exit 1;}


if test "${OBJ_SVNREVISION}" -lt "${SRC_SVNREVISION}"; then
    echo "OBJ_SVNREVISION is lesser than SRC_SVNREVISION."
    echo "Have buildworld and buildkernel been run in buildjail yet?"
    exit 1
fi


# TODO: Updating the build jail that is used to update the build
# host should be done only after updating the build host.
# However, update of other build jails can be done at any time.


# Test if the buildjail has already been snapshotted
# @SVNREVISION
# TODO: Test the ZFS user properties as well, they will show
# directly if the jail is up to date.
if rdnzl_zfs_snapshot_exists "${BUILDJAIL_FS}@${OBJ_SVNREVISION}"; then
    echo "Snapshot ${BUILDJAIL_FS}@${OBJ_SVNREVISION} already exists."
    echo "Jail ${BUILDJAIL} is very likely already up to date."
    # TODO: Test if the snapshot has dependent clones. Stop here if it does.
fi


# TODO: Check that BUILDJAIL is running before trying to launch anything in it.

# Run the 'make installworld', 'mergemaster', 'make delete-old delete-old-libs'
# sequence in the build jail.

# make installworld
rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src installworld || \
    { echo "Can't run 'make installworld' in jail ${BUILDJAIL}}"; exit 1; }

# mergemaster(8)
# TODO: investigate if 'make distrib-dirs distribution' could be used
# instead. The jail is unlikely to have anything worth keeping in
# settings.
rdnzl_in_jail "${BUILDJAIL}" \
    /usr/sbin/mergemaster -Ui --run-updates=always || \
    { echo "Can't run mergemaster(8) in jail ${BUILDJAIL}}"; exit 1; }

# make delete-old delete-old-libs
rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src -D BATCH_DELETE_OLD_FILES delete-old delete-old-libs || \
    { echo "Can't run 'make delete-old' in jail ${BUILDJAIL}}"; exit 1; }



# Record the installed revision in a ZFS user property.
# Snapshot the build jail dataset @SVNREVISION
"${ZFS_CMD}" set "${SVNREVISIONPROP}=${OBJ_SVNREVISION}" \
    "${BUILDJAIL_FS}"

# TODO: Check if the snapshot exists already, delete first when needed
# TODO: The snapshot is not used anymore for anything, maybe drop it.
"${ZFS_CMD}" snapshot "${BUILDJAIL_FS}@${OBJ_SVNREVISION}"

# Restart the jail.
/usr/sbin/service jail restart "${BUILDJAIL}"
 

