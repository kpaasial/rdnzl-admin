#!/bin/sh


# Script that creates a ZFS clone jail(8) out of existing jail
# that is on a ZFS dataset. 

# Modifications done by poudriere should be undo before deleting
# clones by deleting the jail with 'poudriere jail -d -j ...'


# Default dataset paths are:
# zfspool/DATA/jails/basejail - the jail to be cloned
# zfspool/DATA/jails/clonejail - the created clone from basejail
# zfspool/DATA/src/branch/version - the system sources


# Functions

PREFIX=$(dirname $(dirname "$0") )
SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/rdnzl-zfs-functions.sh"
. "${SHARE_RDNZL}/rdnzl-svn-functions.sh"
. "${PREFIX}/etc/rdnzl-admin/sysupdate-setup.rc"

usage()
{
    echo "Usage: $0 [-h] [-B buildjail] [-C clonejail] [-b branch] [-v version]" 
    exit 1
}


# Defaults for settings

: ${BRANCH:="stable"}

: ${BRANCHVERSION:="10"}

: ${BASEJAIL:="buildstable10amd64"}

: ${CLONEJAIL:="clonestable10amd64"}

# Parse command line arguments to override the defaults.

while getopts "B:b:C:fhv:" o
do
    case "$o" in
    B)  BASEJAIL="$OPTARG";;
    b)  BRANCH="$OPTARG";;
    C)  CLONEJAIL="$OPTARG";;
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

# SVN revision of the source tree
SVNREVISION=$(rdnzl_svn_get_revision "${SRC_PATH}") || \
    { echo "Can't get SVN revision for ${SRC_PATH}"; exit 1;}

BRANCHOFSOURCES=$(rdnzl_svn_get_branch "${SRC_PATH}") || \
    { echo "Can't get SVN branch for ${SRC_PATH}"; exit 1;}

SRC_SNAPSHOT="${SRC_FS}@${SVNREVISION}"

# Base jail dataset.
BASEJAILFS="${JAIL_BASEFS}/${BASEJAIL}"


# Dataset for the cloned jail
CLONEJAILFS="${JAIL_BASEFS}/${CLONEJAIL}"

# Dataset for the cloned src tree, created under ${CLONEJAILFS}.
CLONESRCFS="${CLONEJAILFS}/src"


# Bit of debug output...

echo "BRANCHOFSOURCES: ${BRANCHOFSOURCES}"

echo "BRANCH/VERSION requested: ${BRANCH}/${BRANCHVERSION}"

echo "SVNREVISION: ${SVNREVISION}"

echo "BASEJAILFS: ${BASEJAILFS}"

echo "CLONEJAILFS: ${CLONEJAILFS}"

echo "CLONESRCFS: ${CLONESRCFS}"



# Check that the branch of the sources matches what is wanted,
# error out if not.

# TODO: This might be redundant. If the detected branch/version does not match
# what was requested there is an error in the system sources hierarchy.
if test "${BRANCHOFSOURCES}" != "${BRANCH}/${BRANCHVERSION}"; then
    echo "Branch and version of sources ${BRANCHOFSOURCES} does not match requested ${BRANCH}/${BRANCHVERSION}"
    exit 1
fi

# TODO: Check that we are matching sources from the right branch/version
# to the clone jail we are about the create. In other words, match
# BRANCHOFSOURCES to the branch of the buildjail.


#  Require that the snapshot of the system sources exists.
if ! rdnzl_zfs_snapshot_exists "${SRC_SNAPSHOT}"; then
    echo "Error: Snapshot ${SRC_SNAPSHOT} does not exist."
    echo "Create the source snapshot and update ${BASEJAIL} first."
    exit 1
fi

# Test that the base jail snapshot exists, otherwise stop with an error.
if ! rdnzl_zfs_snapshot_exists "${BASEJAILFS}@${SVNREVISION}"; then
    echo "Error: Snapshot ${BASEJAILFS}@${SVNREVISION} does not exist."
    echo "Update and snapshot ${BASEJAIL} to revision ${SVNREVISION} first."
    exit 1
fi


if rdnzl_zfs_filesystem_exists "${CLONEJAILFS}"; then
    if $(poudriere jail -ql | grep -q "${CLONEJAIL}"); then
        echo "A poudriere jail using the filesystem ${CLONEJAILFS} exists."
        echo "Delete it first."
        exit 1
    fi

fi


# Now that we know the CLONEJAILFS either does not exist
# or if it does it's not in use by a poudriere jail we can
# create or recreate it.

# Destroy the filesystems in reverse order of creation.


# The -r flag for destroy is to make sure any snapshots are also destroyed.
if rdnzl_zfs_filesystem_exists "${CLONESRCFS}"; then
    echo "Notice: Filesystem ${CLONESRCFS} already exists."
    echo "It will be destroyed and recreated using the new snapshot of the system sources".    
    "${ZFS_CMD}" destroy -r "${CLONESRCFS}" 
fi


# Check if the CLONEJAIL dataset already exists. Note the user
# if exists and that it is being deleted.
# The -r flag for destroy for the same reason as above.
if rdnzl_zfs_filesystem_exists "${CLONEJAILFS}"; then
    echo "Notice: Filesystem ${CLONEJAILFS} already exists."
    echo "It will be destroyed and recreated using the new snapshot of the build jail".    
    "${ZFS_CMD}" destroy -r "${CLONEJAILFS}" 
fi


# Create a clone dataset from the basejail snapshot.
# TODO: Handle errors
"${ZFS_CMD}" clone \
    -o info.rdnzl:branch="${BRANCHOFSOURCES}" \
    -o info.rdnzl:svnrevision="${SVNREVISION}" \
    "${BASEJAILFS}@${SVNREVISION}" "${CLONEJAILFS}"



# Construct the mountpoint for ${CLONESRCFS}
CLONEJAILPATH=$(rdnzl_zfs_get_property_value "${CLONEJAILFS}" "mountpoint")

CLONESRCPATH="${CLONEJAILPATH}/usr/src"

echo "CLONESRCPATH: ${CLONESRCPATH}"

# Create the clone src dataset from the system sources snapshot.
# This is essentially doing the same as build-jail.sh for the build jail.
# Set the clone to be read-only.
# TODO: Handle errors
"${ZFS_CMD}" clone \
    -o readonly=on \
    -o mountpoint="${CLONESRCPATH}" \
    -o info.rdnzl:branch="${BRANCHOFSOURCES}" \
    -o info.rdnzl:svnrevision="${SVNREVISION}" \
     "${SRC_SNAPSHOT}" "${CLONESRCFS}"

