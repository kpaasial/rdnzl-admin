#!/bin/sh


# Another take on creating poudriere -m null jails
# from build(7) jails.


# The idea is to create a new ZFS filesystem, mount it temporarily
# under the build jail hierarchy (for example /data/jails/buildjail/mnt)
# and run 'make installworld distrib-dirs distribute DB_FROM_SRC=1'
# inside the buildjail with DESTDIR set to /mnt (inside the jail).
# This will install a completely clean world to the new portsjail.

# System sources are ZFS cloned to jail /usr/src using the snapshot of the
# sources @SVNREVISION.

# TODO: Remove debug prints. Add proper notices where appropriate. 

# TODO: This is not really part of the sysupdate suite. It probably
# belongs to ../ports.

PREFIX="@@PREFIX@@"
SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/rdnzl-zfs-functions.sh"
. "${SHARE_RDNZL}/rdnzl-svn-functions.sh"
. "${SHARE_RDNZL}/rdnzl-jail-functions.sh"
. "${PREFIX}/etc/rdnzl-admin/sysupdate-setup.rc"

usage()
{
    echo "Usage: $0 buildjail portsjail" 
    exit 1
}


: ${BUILDJAIL:="$1"}

# Buildjail is a required argument, there is no reasonable default.
if test -z "${BUILDJAIL}"; then
    usage
fi


: ${PORTSJAIL:="$2"}

# Portsjail is a required argument, there is no reasonable default.
if test -z "${PORTSJAIL}"; then
    usage
fi


# SVNBRANCH and SVNREVISION are fixed by build-sources.sh into the
# /usr/obj filesystem of the buildjail. They are read here from that
# filesystem. 

# Read the SVN revisions from the buildjail filesystems

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



SRC_SVNREVISION=$(rdnzl_zfs_get_property_value "${BUILDJAILSRC_FS}" "${SVNREVISIONPROP}") || \
    { echo "Can not read SVNREVISION from filesystem ${BUILDJAILSRC_FS}"; exit 1;}

OBJ_SVNREVISION=$(rdnzl_zfs_get_property_value "${BUILDJAILOBJ_FS}" "${SVNREVISIONPROP}") || \
    { echo "Can not read SVNREVISION from filesystem ${BUILDJAILOBJ_FS}"; exit 1;}

# We actually need this to know which branch we are installing to the new portsjail.
OBJ_SVNBRANCH=$(rdnzl_zfs_get_property_value "${BUILDJAILOBJ_FS}" "${SVNBRANCHPROP}") || \
    { echo "Can not read SVNBRANCH from filesystem ${BUILDJAILOBJ_FS}"; exit 1;}

# Have the sources been used for 'make buildworld etc.'?
if test "${OBJ_SVNREVISION}" -lt "${SRC_SVNREVISION}"; then
    echo "OBJ_SVNREVISION is lesser than SRC_SVNREVISION."
    echo "Have buildworld and buildkernel been run in buildjail yet?"
    exit 1
fi

# Dataset for the new portsjail
PORTSJAIL_FS="${JAIL_BASEFS}/${PORTSJAIL}"

# This is needed for cloning of the system sources to portsjail /usr/src.
SRC_FS="${SRC_BASEFS}/${OBJ_SVNBRANCH}"

SRC_SNAPSHOT="${SRC_FS}@${OBJ_SVNREVISION}"


#  Require that the snapshot of the system sources exists.
if ! rdnzl_zfs_snapshot_exists "${SRC_SNAPSHOT}"; then
    echo "Error: System sources snapshot ${SRC_SNAPSHOT} does not exist."
    exit 1
fi


# Check if the PORTSJAIL dataset already exists. Note the user
# if exists and that it is being deleted. The -r flag for destroy 
# is for any snapshots such as @clean and the src child fs.
# Note: If there is a poudriere jail (or anything else that requires
# dismantling) on the filesystem this script will not know that,
# it's for the user of this script to handle.
if rdnzl_zfs_filesystem_exists "${PORTSJAIL_FS}"; then
    echo "Notice: Filesystem ${PORTSJAIL_FS} already exists."
    echo "It will be destroyed and recreated."   
    "${ZFS_CMD}" destroy -r "${PORTSJAIL_FS}" 
fi


# First (re)create the ${PORTSJAILFS}
# Here we do need OBJ_SVNBRANCH, nothing to inherit the SVNBRANCH from.
# Both properties have to be set explicitly here.
"${ZFS_CMD}" create \
    -o "${SVNBRANCHPROP}"="${OBJ_SVNBRANCH}" \
    -o "${SVNREVISIONPROP}"="${OBJ_SVNREVISION}" \
    "${PORTSJAIL_FS}"


# Get the mountpoints of the buildjail and the portsjail.
BUILDJAIL_MNT=$(rdnzl_zfs_get_property_value "${BUILDJAIL_FS}" "mountpoint")
PORTSJAIL_MNT=$(rdnzl_zfs_get_property_value "${PORTSJAIL_FS}" "mountpoint")

# Then mount the new ports jail under ${BUILDJAILFS}/mnt 
# TODO: Use a temporary random directory instead of /mnt to avoid collisions
# with other tools.

"${ZFS_CMD}" set mountpoint="${BUILDJAIL_MNT}/mnt" "${PORTSJAIL_FS}"

# Run 'make installworld' etc in the buildjail 
# TODO: Handle errors.
rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src installworld DESTDIR=/mnt DB_FROM_SRC=1

rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src distrib-dirs DESTDIR=/mnt DB_FROM_SRC=1

rdnzl_in_jail "${BUILDJAIL}" \
    /usr/bin/make -C /usr/src distribution DESTDIR=/mnt DB_FROM_SRC=1


# Reset mountpoint of PORTSJAIL_FS to the default
# to mount it in its final destination.

"${ZFS_CMD}" inherit mountpoint "${PORTSJAIL_FS}"

# Setup /usr/src for the new jail by using a clone of the source snapshot  

PORTSJAILSRC_MNT="${PORTSJAIL_MNT}/usr/src"

# Create the clone src dataset from the system sources snapshot.
# Set the clone to be read-only.
# No need to set the user properties, they will be inherited
# correctly from the PORTSJAIL_FS.
# TODO: Handle errors
"${ZFS_CMD}" clone \
    -o readonly=on \
    -o mountpoint="${PORTSJAILSRC_MNT}" \
     "${SRC_SNAPSHOT}" "${PORTSJAIL_FS}/src"

# Extra bit of setup for the new jail
/bin/cp /etc/localtime  "${PORTSJAIL_MNT}/etc/localtime"

# TODO: Maybe some more extra set up is needed, not known at the moment.


