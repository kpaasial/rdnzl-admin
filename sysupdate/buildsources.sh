#!/bin/sh


# This script does the buildworld/buildkernel part of the update process.
# Prerequisites are that the buildjail exists and a new set of sources
# has been set up by setup-buildjail.sh in buildjail /usr/src and
# a new clean /usr/obj filesystem also exists in the buildjail.

PREFIX="@@PREFIX@@"


SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/zfs-functions.sh"
. "${SHARE_RDNZL}/jail-functions.sh"
. "${SHARE_RDNZL}/sysupdate-common.sh"
. "${PREFIX}/etc/rdnzl/sysupdate.rc"


usage()
{
    echo "Usage: $0 buildjail" 
    exit 1
}


NCPU=$(/sbin/sysctl -n hw.ncpu)

: ${BUILDJAIL:="$1"}

# Buildjail is a required argument, there is no reasonable default.
if test -z "${BUILDJAIL}"; then
    usage
fi

# Build jail filesystem
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
    echo "No such buildjail obj filesystem ${BUILDJAILOBJ_FS}"
    exit 1
fi


# Extract the src and obj branches and revisions
SRC_SVNREVISION=$(rdnzl_zfs_get_property_value "${BUILDJAILSRC_FS}" "${SVNREVISIONPROP}") || \
    { echo "Can not read SVNREVISION from filesystem ${BUILDJAILSRC_FS}"; exit 1;}

OBJ_SVNREVISION=$(rdnzl_zfs_get_property_value "${BUILDJAILOBJ_FS}" "${SVNREVISIONPROP}") || \
    { echo "Can not read SVNREVISION from filesystem ${BUILDJAILOBJ_FS}"; exit 1;}


# If the sources have higher SVNREVISION than the objects we will launch
# 'make buildworld buildkernel' in the buildjail.

# TODO: What if the user really wants to go backwards in revisions or rebuild
# using the same revision? Require -f flag probably...

if test "${SRC_SVNREVISION}" -gt "${OBJ_SVNREVISION}"; then
    echo "Sources at buildjail ${BUILDJAIL} are newer than the objects."
    echo "Launching 'make buildworld buildkernel'"

    # TODO: Set up automatic logging of builds and installs.
    rdnzl_in_jail "${BUILDJAIL}" /usr/bin/make -C /usr/src -j "${NCPU}" \
        buildworld buildkernel || \
    { echo "'make buildworld buildkernel' failed."; exit 1;}

    # Record the new SVNREVISION (of the sources used) to the buildjail /usr/obj filesystem
    "${ZFS_CMD}" set "${SVNREVISIONPROP}=${SRC_SVNREVISION}" \
        "${BUILDJAILOBJ_FS}"
fi
