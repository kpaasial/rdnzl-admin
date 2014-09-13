#!/bin/sh

# Script for automatically mounting a new set of sources in a build jail.
# This is run after using svn/svnlite to update the sources.

# Creates a snapshot of the sources and a ZFS clone using the
# snapshot and mounts the clone on the desired jail under the jail
# /usr/src -directory.

# After running this script 'make buildworld buildkernel'
# followed by the usual update procedure should be run on the
# host. The script update-host automates this procedure as much
# as possible. 
  
# After the host has been updated with new kernel and world using
# the update-host.sh script the build jail should be updated by
# running the update-buildjail.sh script.

# TODO: Write a script to automate the buildworld/buildkernel procedure.



# TODO: Write a rdnzl-common-functions.sh with functions that make all the following
# a bit easier
PREFIX=$(dirname $(dirname "$0") )
SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/rdnzl-zfs-functions.sh"
. "${SHARE_RDNZL}/rdnzl-svn-functions.sh"
. "${PREFIX}/etc/rdnzl-admin/sysupdate-setup.rc"


usage()
{
    echo "$0 [-hf] [-B buildjail] [-b branch] [-v version]" 
    exit 0
}

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

SRC_PATH=$(rdnzl_zfs_get_property_value "${SRC_FS}" "mountpoint") || \
    { echo "No sources exist for ${BRANCH}/${BRANCHVERSION}"; exit 1;}

echo "SRC_PATH: ${SRC_PATH}"

 
# SVN revision of the source tree

SVNREVISION=$(rdnzl_svn_get_revision "${SRC_PATH}") || \
    { echo "Can't get SVN revision for ${SRC_PATH}"; exit 1;}

BRANCHOFSOURCES=$(rdnzl_svn_get_branch "${SRC_PATH}") || \
    { echo "Can't get SVN branch for ${SRC_PATH}"; exit 1;}

SRC_SNAPSHOT="${SRC_FS}@${SVNREVISION}"

# Base jail dataset.
BUILDJAIL_FS="${JAIL_BASEFS}/${BUILDJAIL}"

# Test the obvious right away, does the BUILDJAIL_FS exist.
# If not there's no point in continuing
if ! rdnzl_zfs_filesystem_exists "${BUILDJAIL_FS}"; then
    echo "No such buildjail filesystem: ${BUILDJAIL_FS}."
    exit 1
fi



# Dataset for the cloned src tree, created under ${BUILDJAILFS}.
# Branch and SVN revision information stored in ZFS user properties
BUILDJAILSRC_FS="${BUILDJAIL_FS}/src"

# Dataset for /usr/obj in the buildjail
BUILDJAILOBJ_FS="${BUILDJAIL_FS}/obj"

# Construct the mountpoint for BUILDJAILSRC_FS
BUILDJAIL_PATH=$(rdnzl_zfs_get_property_value "${BUILDJAIL_FS}" "mountpoint")

BUILDJAILSRC_PATH="${BUILDJAIL_PATH}/usr/src"

# Same for BUILDJAILOBJ_FS
BUILDJAILOBJ_PATH="${BUILDJAIL_PATH}/usr/obj"


# Bit of debug output...

echo "BRANCHOFSOURCES: ${BRANCHOFSOURCES}"

echo "BRANCH/VERSION requested: ${BRANCH}/${BRANCHVERSION}"

echo "SVNREVISION: ${SVNREVISION}"

echo "SRC_SNAPSHOT: ${SRC_SNAPSHOT}"

echo "BUILDJAIL_FS: ${BUILDJAIL_FS}"

echo "BUILDJAILSRC_FS: ${BUILDJAILSRC_FS}"



# Create a snapshot of the source code dataset.
# The snapshot name is the SVN revision of the matching sources
if rdnzl_zfs_snapshot_exists "${SRC_SNAPSHOT}"; then
    echo "Notice: Snapshot ${SRC_SNAPSHOT} already exists, not creating it again."
else
    echo "Creating snapshot ${SRC_SNAPSHOT}"
    "${ZFS_CMD}" snapshot "${SRC_SNAPSHOT}"
fi


# TODO: Check that BUILDJAILSRC_PATH is not a target for another
# mount, for example a nullfs mount to the host /usr/src.
# On that note, /usr/src and /usr/obj that are used to update the host
# could be clones as well so that their contents can be controlled.
# This would mean snapshotting and cloning of the jail /usr/obj
# dataset as well.

# Test if ${BUILDJAILSRC_FS} already exists.
# The -r flag for destroy is for the case there are snapshots on the dataset
# for whatever reason.
if rdnzl_zfs_filesystem_exists "${BUILDJAILSRC_FS}"; then
    echo "Notice: A clone of the system sources already exists at ${BUILDJAILSRC_FS}."
    echo "Destroying ${BUILDJAILSRC_FS}."
    "${ZFS_CMD}" destroy -r "${BUILDJAILSRC_FS}"    
fi


# Create the clone src dataset from the system sources snapshot. 
echo "Creating a new clone of the system sources from snapshot ${SRC_SNAPSHOT} at ${BUILDJAILSRC_FS}."
echo "SVNREVISION: ${SVNREVISION}"
echo "BRANCHOFSOURCES: ${BRANCHOFSOURCES}"
echo "Mountpoint: ${BUILDJAILSRC_PATH}"

"${ZFS_CMD}" clone -o mountpoint="${BUILDJAILSRC_PATH}" \
    -o readonly=on -o atime=off \
    -o "${USERPROPBASE}:svnrevision"="${SVNREVISION}" \
    -o "${USERPROPBASE}:branch"="${BRANCHOFSOURCES}" \
    "${SRC_SNAPSHOT}" "${BUILDJAILSRC_FS}"



# Destroy the jail /usr/obj dataset if it (very likely) exists.
# This will reset the build number to #0 every time the sources
# are updated. The -r flag for destroy for the same reason as above.

# TODO: This will fail if the jail /usr/obj is in use by another
# mount, for example nullfs mount to host /usr/obj. NFS export might
# do the same?
if rdnzl_zfs_filesystem_exists "${BUILDJAILOBJ_FS}"; then
    echo "Dataset for the jail /usr/obj already exists."
    echo "Destroying ${BUILDJAILOBJ_FS}"
    "${ZFS_CMD}" destroy -r "${BUILDJAILOBJ_FS}"
fi

# Create a new filesystem for the jail /usr/obj directory.
echo "Creating a new dataset for ${BUILDJAILOBJ_PATH} at ${BUILDJAILOBJ_FS}."
"${ZFS_CMD}" create -o mountpoint="${BUILDJAILOBJ_PATH}" \
    -o atime=off "${BUILDJAILOBJ_FS}"
