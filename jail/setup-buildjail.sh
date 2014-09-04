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

# Functions

. rdnzl-zfs-functions.sh
. rdnzl-svn-functions.sh
. rdnzl-jailtools-setup.sh

#: ${SVN_CMD:=$(which svn 2>/dev/null || which svnlite 2>/dev/null)}

# Defaults for settings

# The name of the ZFS pool
: ${ZFS_POOL:="rdnzltank"}

# Where the system sources are stored
: ${SRC_BASEFS:="${ZFS_POOL}/DATA/src"}

# Base dataset for jails
: ${JAIL_BASEFS:="${ZFS_POOL}/DATA/jails"}

: ${BRANCH:="stable"}

: ${BRANCHVERSION:="10"}

: ${BUILDJAIL:="buildstable10amd64"}


# Parse command line arguments to override the defaults.

while getopts "B:b:fv:" o
do
    case "$o" in
    B)  BUILDJAIL="$OPTARG";;
    b)  BRANCH="$OPTARG";;
    f)  FORCE_MODE=1;;
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

# Dataset for the cloned src tree, created under ${BUILDJAILFS}.
# Branch and SVN revision information stored in ZFS user properties
BUILDJAILSRC_FS="${BUILDJAIL_FS}/src"


# Base part of the ZFS user properties used
#ZFSUSERPROPBASE="info.rdnzl.jailutils"

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

# Construct the mountpoint for ${BUILDJAILSRC_FS}
BUILDJAIL_PATH=$(rdnzl_zfs_get_property_value "${BUILDJAIL_FS}" "mountpoint")

BUILDJAILSRC_PATH="${BUILDJAIL_PATH}/usr/src"


# TODO: Check that BUILDJAILSRC_PATH is not a target for another
# mount, for example a nullfs mount to the host /usr/src.
# On that note, /usr/src and /usr/obj that are used to update the host
# could be clones as well so that their contents can be controlled.
# This would mean snapshotting and cloning of the jail /usr/obj
# dataset as well.

# Test if ${BUILDJAILSRC_FS} already exists.
# TODO: Test if the new clone would be from the same SVNREVISION of the sources as the
# existing one. Require the force mode if that is the case.
if rdnzl_zfs_filesystem_exists "${BUILDJAILSRC_FS}"; then
    echo "Notice: A clone of the system sources already exists at ${BUILDJAILSRC_FS}."
    echo "Destroying ${BUILDJAILSRC_FS}."
    "${ZFS_CMD}" destroy "${BUILDJAILSRC_FS}"    
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



