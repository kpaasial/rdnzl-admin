#!/bin/sh


# Another take on creating poudriere -m null jails
# from build(7) jails.


# The idea is to create a new ZFS filesystem, nullfs mount it under the
# build jail hierarchy (for example /buildjail/mnt) and run
# 'make installworld distrib-dirs distribute DB_FROM_SRC=1'
# inside the buildjail with DESTDIR set to /mnt (inside the jail).
# This will install a completely clean world every time the
# poudriere jail is updated.

# System sources are copied to the portsjail /usr/src using the snapshot of the
# sources @ latest SVNREVISION.


# Functions

PREFIX=$(dirname $(dirname "$0") )
SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/rdnzl-zfs-functions.sh"
. "${SHARE_RDNZL}/rdnzl-svn-functions.sh"
. "${SHARE_RDNZL}/rdnzl-jail-functions.sh"
. "${PREFIX}/etc/rdnzl-admin/sysupdate-setup.rc"

usage()
{
    echo "Usage: $0 [-h] [-B buildjail] [-P portsjail] [-b branch] [-v version]" 
    exit 1
}


# Defaults for settings

: ${BRANCH:="stable"}

: ${BRANCHVERSION:="10"}

: ${BUILDJAIL:="buildstable10amd64"}

: ${PORTSJAIL:="portsstable10amd64"}

# Parse command line arguments to override the defaults.

while getopts "B:b:fhP:v:" o
do
    case "$o" in
    B)  BUILDJAIL="$OPTARG";;
    b)  BRANCH="$OPTARG";;
    f)  FORCE_MODE=1;;
    h)  usage;;
    P)  PORTSJAIL="$OPTARG";;
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
BUILDJAIL_FS="${JAIL_BASEFS}/${BUILDJAIL}"


# Dataset for the ports jail
PORTSJAIL_FS="${JAIL_BASEFS}/${PORTSJAIL}"


# Bit of debug output...

echo "BRANCHOFSOURCES: ${BRANCHOFSOURCES}"

echo "BRANCH/VERSION requested: ${BRANCH}/${BRANCHVERSION}"

echo "SVNREVISION: ${SVNREVISION}"

echo "BASEJAIL_FS: ${BASEJAIL_FS}"

echo "PORTSJAIL_FS: ${PORTSJAIL_FS}"




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
    exit 1
fi



if rdnzl_zfs_filesystem_exists "${PORTSJAIL_FS}"; then
    if $(poudriere jail -ql | grep -q "${PORTSJAIL}"); then
        echo "A poudriere jail using the filesystem ${PORTSJAIL_FS} exists."
        echo "Delete it first."
        exit 1
    fi

fi


# Now that we know the CLONEJAILFS either does not exist
# or if it does it's not in use by a poudriere jail we can
# create or recreate it.



# Check if the PORTSJAIL dataset already exists. Note the user
# if exists and that it is being deleted.
# The -r flag for destroy for the same reason as above.
if rdnzl_zfs_filesystem_exists "${PORTSJAIL_FS}"; then
    echo "Notice: Filesystem ${PORTSJAIL_FS} already exists."
    echo "It will be destroyed and recreated."   
    "${ZFS_CMD}" destroy -r "${PORTSJAIL_FS}" 
fi


# First (re)create the ${PORTSJAILFS}
"${ZFS_CMD}" create \
    -o info.rdnzl:branch="${BRANCHOFSOURCES}" \
    -o info.rdnzl:svnrevision="${SVNREVISION}" \
    "${PORTSJAIL_FS}"


# Get the mountpoints of the buildjail and the ports jail
BUILDJAIL_MNT=$(rdnzl_zfs_get_property_value "${BUILDJAIL_FS}" "mountpoint")


PORTSJAIL_MNT=$(rdnzl_zfs_get_property_value "${PORTSJAIL_FS}" "mountpoint")

# Then mount the new ports jail under ${BUILDJAILFS}/mnt 
"${ZFS_CMD}" set mountpoint="${BUILDJAIL_MNT}/mnt" "${PORTSJAIL_FS}"

# Run 'make installworld' etc in the buildjail 
rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src installworld DESTDIR=/mnt DB_FROM_SRC=1

rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src distrib-dirs DESTDIR=/mnt DB_FROM_SRC=1

rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src distribution DESTDIR=/mnt DB_FROM_SRC=1

"${ZFS_CMD}" inherit mountpoint "${PORTSJAIL_FS}"

# Setup /usr/src for the new jail by using a clone of the source snapshot  

PORTSJAILSRC_MNT="${PORTSJAIL_MNT}/usr/src"

echo "PORTSJAILSRC_MNT: ${PORTSJAILSRC_MNT}"

# Create the clone src dataset from the system sources snapshot.
# Set the clone to be read-only.
# TODO: Handle errors
"${ZFS_CMD}" clone \
    -o readonly=on \
    -o mountpoint="${PORTSJAILSRC_MNT}" \
    -o info.rdnzl:branch="${BRANCHOFSOURCES}" \
    -o info.rdnzl:svnrevision="${SVNREVISION}" \
     "${SRC_SNAPSHOT}" "${PORTSJAIL_FS}/src"





