#!/bin/sh

# Script for automatically mounting a new set of sources in a build jail.
# This is run after using svn/svnlite to update the sources.

# Creates a snapshot of the sources and a ZFS clone using the
# snapshot and mounts the clone on the desired jail under the jail
# /usr/src -directory.



# Functions

get_mountpoint()
{
    ZFSFS=$1
    /sbin/zfs get -H -o value mountpoint "$ZFSFS"
}




: ${SVN_CMD:=$(which svn 2>/dev/null || which svnlite 2>/dev/null)}

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

SRC_PATH=$(/sbin/zfs get -H -o value mountpoint ${SRC_FS}) || \
    { echo "No sources exist for ${BRANCH}/${BRANCHVERSION}"; exit 1;}

# SVN revision of the source tree
SVNREVISION="$(${SVN_CMD} info ${SRC_PATH} | awk '/^Revision:/ {print $2}')"

BRANCHOFSOURCES=$(${SVN_CMD} info ${SRC_PATH} | \
    awk '/^Relative URL:/ {sub(/\^\//,"", $3); print $3}')


SRC_SNAPSHOT="${SRC_FS}@${SVNREVISION}"

# Base jail dataset.
BUILDJAIL_FS="${JAIL_BASEFS}/${BUILDJAIL}"

# Dataset for the cloned src tree, created under ${BUILDJAILFS}.
# Branch and SVN revision information stored in ZFS user properties
BUILDJAILSRC_FS="${BUILDJAIL_FS}/src"


# Bit of debug output...

echo "BRANCHOFSOURCES: ${BRANCHOFSOURCES}"

echo "BRANCH/VERSION requested: ${BRANCH}/${BRANCHVERSION}"

echo "SVNREVISION: ${SVNREVISION}"

echo "SRC_SNAPSHOT: ${SRC_SNAPSHOT}"

echo "BUILDJAIL_FS: ${BUILDJAIL_FS}"

echo "BUILDJAILSRC_FS: ${BUILDJAILSRC_FS}"



# Create a snapshot of the source code dataset.
# The snapshot name is the SVN revision of the matching sources
if $(/sbin/zfs list -t snapshot -H -o name "${SRC_SNAPSHOT}" >/dev/null 2>&1); then
    echo "Notice: Snapshot ${SRC_SNAPSHOT} already exists, not creating it again."
else
    echo "Creating snapshot ${SRC_SNAPSHOT}"
    /sbin/zfs snapshot "${SRC_SNAPSHOT}"
fi


# Construct the mountpoint for ${BUILDJAILSRC_FS}
BUILDJAIL_PATH=$(/sbin/zfs get -H -o value mountpoint "${BUILDJAIL_FS}")

BUILDJAILSRC_PATH="${BUILDJAIL_PATH}/usr/src"


# TODO: Check that BUILDJAILSRC_PATH is not a target for another
# mount, for example a nullfs mount to the host /usr/src

# Make sure that ${BUILDJAILSRC_FS} doesn't already exist.
# Require FORCE_MODE to overwrite it by force.
if /sbin/zfs list -H -o name "${BUILDJAILSRC_FS}" >/dev/null 2>&1; then
    if test -z ${FORCE_MODE}; then
        echo "${BUILDJAILSRC_FS} already exists, destroy it first."
        echo "Run $0 -f to force overwriting of ${BUILDJAILSRC_FS}"
        exit 1
    else
        echo "Destroying ${BUILDJAILSRC_FS}"
        /sbin/zfs destroy "${BUILDJAILSRC_FS}"
    fi
fi


# Create the clone src dataset from the system sources snapshot. 
/sbin/zfs clone -o mountpoint="${BUILDJAILSRC_PATH}" \
    -o readonly=on -o atime=off \
    -o info.rdnzl:svnrevision="${SVNREVISION}" \
    -o info.rdnzl:branch="${BRANCHOFSOURCES}" \
    "${SRC_SNAPSHOT}" "${BUILDJAILSRC_FS}"



