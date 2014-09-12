#!/bin/sh


# Update the build jail with
# 'make installworld' etc. and record the installed svnrevision
# with both ZFS user properties and a snapshot @SVNREVISION. 


# Installed svn revisions of kernel and world should be checked
# on the running system from the recorded ZFS user properties
# on the root filesystem. If they are are found to be less
# than what is on the sources refuse to run because that means
# that update-host.sh hasn't been yet run to completion. 

usage()
{
    echo "Usage: $0 [-h][-B buildjail] [-b branch] [-v version]" 
    exit 0   
}

PREFIX=$(dirname $(dirname "$0") )
SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/rdnzl-zfs-functions.sh"
. "${SHARE_RDNZL}/rdnzl-svn-functions.sh"
. "${PREFIX}/etc/rdnzl-admin/sysupdate-setup.rc"


# Defaults for settings

# The name of the ZFS pool
#: ${ZFS_POOL:="rdnzltank"}

# Where the system sources are stored
: ${SRC_BASEFS:="${ZFS_POOL}/DATA/src"}

# Base dataset for jails
: ${JAIL_BASEFS:="${ZFS_POOL}/DATA/jails"}

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


# TODO: This could actually use the bootfs property of
# of the pool
ROOT_DATASET=$(rdnzl_zfs_filesystem_from_path "/")

echo "ROOT_DATASET: ${ROOT_DATASET}"

INSTALLED_KERNEL_REVISION=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${KERNELREVPROP}")
INSTALLED_KERNEL_BRANCH=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${KERNELBRANCHPROP}")
INSTALLED_WORLD_REVISION=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${WORLDREVPROP}")
INSTALLED_WORLD_BRANCH=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${WORLDBRANCHPROP}")

echo "INSTALLED_KERNEL_REVISION: ${INSTALLED_KERNEL_REVISION}"
echo "INSTALLED_KERNEL_BRANCH: ${INSTALLED_KERNEL_BRANCH}"
echo "INSTALLED_WORLD_REVISION: ${INSTALLED_WORLD_REVISION}"
echo "INSTALLED_WORLD_BRANCH: ${INSTALLED_WORLD_BRANCH}"



# Test that the installed kernel and world are of
# the same branch and revision as the sources
# Stop if they aren't because that would mean the host hasn't been yet updated.
if test "${INSTALLED_KERNEL_BRANCH}" != "${BRANCHOFSOURCES}"; then
    echo "Installed kernel branch ${INSTALLED_KERNEL_BRANCH} does not match "
    echo "the branch of the sources, ${BRANCHOFSOURCES}"
    exit 1
fi

if test "${INSTALLED_WORLD_BRANCH}" != "${BRANCHOFSOURCES}"; then
    echo "Installed world branch ${INSTALLED_WORLD_BRANCH} does not match "
    echo "the branch of the sources, ${BRANCHOFSOURCES}"
    exit 1
fi

if test "${INSTALLED_KERNEL_REVISION}" != "${SVNREVISION}"; then
    echo "Installed kernel revision ${INSTALLED_KERNEL_REVISION} does not match "
    echo "the revision of the sources, ${SVNREVISION}"
    exit 1
fi

if test "${INSTALLED_WORLD_REVISION}" != "${SVNREVISION}"; then
    echo "Installed world revision ${INSTALLED_WORLD_REVISION} does not match "
    echo "the revision of the sources, ${SVNREVISION}"
    exit 1
fi


# Test if the buildjail has already been snapshotted
# @SVNREVISION
if rdnzl_zfs_snapshot_exists "${BUILDJAIL_FS}@${SVNREVISION}"; then
    echo "Snapshot ${BUILDJAIL_FS}@${SVNREVISION} already exists."
    echo "Jail ${BUILDJAIL} is very likely already up to date."
fi

# Run the 'make installworld', 'mergemaster', 'make delete-old delete-old-libs'
# sequence in the build jail.
# TODO: create an in_jail() function for running stuff in a jail.

/usr/sbin/jexec -U root "${BUILDJAIL}" sh /upgrade2.sh || \
    { echo "Can't run upgrade2.sh in jail ${BUILDJAIL}}"; exit 1; }

# Record the installed version and branch in the ZFS user properties.
# Snapshot the build jail dataset @SVNREVISION
"${ZFS_CMD}" set "${USERPROPBASE}:svnrevision=${SVNREVISION}" \
    "${BUILDJAIL_FS}"

"${ZFS_CMD}" set "${USERPROPBASE}:branch=${BRANCHOFSOURCES}" \
    "${BUILDJAIL_FS}"

"${ZFS_CMD}" snapshot "${BUILDJAIL_FS}@${SVNREVISION}"

# Restart the jail.
/usr/sbin/service jail restart "${BUILDJAIL}"
 

