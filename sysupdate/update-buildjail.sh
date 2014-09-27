#!/bin/sh


# Update the build jail with
# 'make installworld' etc. and record the installed svnrevision
# with both ZFS user properties and a snapshot @SVNREVISION. 

usage()
{
    echo "Usage: $0 [-h][-B buildjail] [-b branch] [-v version]" 
    exit 0   
}

PREFIX="/opt"
SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/rdnzl-zfs-functions.sh"
. "${SHARE_RDNZL}/rdnzl-svn-functions.sh"
. "${SHARE_RDNZL}/rdnzl-jail-functions.sh"
. "${PREFIX}/etc/rdnzl-admin/sysupdate-setup.rc"


# Defaults for settings

: ${BRANCH:="stable"}

: ${BRANCHVERSION:="10"}

: ${BUILDJAIL:="buildstable10amd64"}


# Parse command line arguments to override the defaults.

while getopts "B:b:fhv:" o
do
    case "$o" in
    B)  BUILDJAIL="$OPTARG";;
    b)  BRANCH="$OPTARG";;
    f)  FORCE_MODE=1;;
    h)  usage;;
    v)  BRANCHVERSION="$OPTARG";;
    *)  usage;;
    esac

done

shift $((OPTIND-1))




SRC_FS="${SRC_BASEFS}/${BRANCH}/${BRANCHVERSION}"

SRC_PATH=$(rdnzl_zfs_get_property_value "${SRC_FS}" mountpoint) || \
    { echo "No sources exist for ${BRANCH}/${BRANCHVERSION}"; exit 1;}

# SVN revision of the source tree
SVNREVISION=$(rdnzl_svn_get_revision "${SRC_PATH}") || \
    { echo "Can't get SVN revision for ${SRC_PATH}"; exit 1;}

BRANCHOFSOURCES=$(rdnzl_svn_get_branch "${SRC_PATH}") || \
    { echo "Can't get SVN branch for ${SRC_PATH}"; exit 1;}

# Build jail
BUILDJAIL_FS="${JAIL_BASEFS}/${BUILDJAIL}"


# TODO: Updating the build jail that is used to update the build
# host should be done only after updating the build host.
# However, update of other build jails can be done at any time.


# TODO: Running this on an upto date build jail won't work
# probably because the snapshot @SVNREVISION will very likely 
# have a dependent clone.

# Test if the buildjail has already been snapshotted
# @SVNREVISION
# TODO: Test the ZFS user properties as well, they will show
# directly if the jail is up to date.
if rdnzl_zfs_snapshot_exists "${BUILDJAIL_FS}@${SVNREVISION}"; then
    echo "Snapshot ${BUILDJAIL_FS}@${SVNREVISION} already exists."
    echo "Jail ${BUILDJAIL} is very likely already up to date."
    # TODO: Test if the snapshot has dependent clones. Stop here if it does.
fi

# Run the 'make installworld', 'mergemaster', 'make delete-old delete-old-libs'
# sequence in the build jail.
# TODO: create an in_jail() function for running stuff in a jail.

# make installworld
rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src installworld || \
    { echo "Can't run 'make installworld' in jail ${BUILDJAIL}}"; exit 1; }

# mergemaster(8)
rdnzl_in_jail "${BUILDJAIL}" \
    /usr/sbin/mergemaster -Ui --run-updates=always || \
    { echo "Can't run mergemaster(8) in jail ${BUILDJAIL}}"; exit 1; }

# make delete-old delete-old-libs
rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src -D BATCH_DELETE_OLD_FILES delete-old delete-old-libs || \
    { echo "Can't run 'make delete-old' in jail ${BUILDJAIL}}"; exit 1; }



# Record the installed version and branch in the ZFS user properties.
# Snapshot the build jail dataset @SVNREVISION
"${ZFS_CMD}" set "${USERPROPBASE}:svnrevision=${SVNREVISION}" \
    "${BUILDJAIL_FS}"

"${ZFS_CMD}" set "${USERPROPBASE}:branch=${BRANCHOFSOURCES}" \
    "${BUILDJAIL_FS}"

"${ZFS_CMD}" snapshot "${BUILDJAIL_FS}@${SVNREVISION}"

# Restart the jail.
/usr/sbin/service jail restart "${BUILDJAIL}"
 

