#!/bin/sh

# Script for updating the host using the build(7) results
# from a buildjail.

# Two modes of operation.

# First mode runs the 'make installkernel' part of the update
# procedure. Also records the installed kernel version with 
# ZFS user properties on the root filesystem.

# TODO: Remove debug prints. Add proper notices where appropriate. 

# TODO: Explore the usefulness of recording of sha256 hash of the
# installed kernel into the ZFS user properties. A mismatch would mean
# that 'make installkernel' has been run and /boot/kernel/kernel has changed. 

# TODO: Guarantee atomicity of the operation. Either both the kernel
# gets installed successfully and the ZFS property operations are
# finished or the operations get rolled back to the initial state 
# in case of any error. 


# Second mode is run after update of world to record the installed
# world version using another set of ZFS user properties
# on the root filesystem.



# The mode can be autodetected by looking at the ZFS user
# properties on the ZFS root filesystem. If the recorded 
# ${SVNREVISION} of the kernel is less than what is on the
# sources it can be deduced that this script hasn't been
# yet run in the first mode to install the new kernel.
#
# Otherwise the second mode should be used.

# Include common functions and settings

PREFIX="@@PREFIX@@"
SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/rdnzl-zfs-functions.sh"
. "${SHARE_RDNZL}/rdnzl-svn-functions.sh"
. "${PREFIX}/etc/rdnzl-admin/sysupdate-setup.rc"


usage()
{
    echo "Usage: $0 [-W] buildjail " 
    exit 0
}

# Defaults for settings.
INSTALL_MODE="kernel"

# Parse command line arguments to override the defaults.
# TODO: Add a -n flag for testrun option to see what would
# be done.
while getopts "hW" o
do
    case "$o" in
    h)  usage;;
    W)  INSTALL_MODE="world";;
    *)  usage;;
    esac

done

shift $((OPTIND-1))

: ${BUILDJAIL:="$1"}

# Buildjail is a required argument, there is no reasonable default.
if test -z "${BUILDJAIL}"; then
    usage
fi


# Read the SVN revision from the buildjail

BUILDJAIL_FS="${JAIL_BASEFS}/${BUILDJAIL}"
BUILDJAILSRC_FS="${BUILDJAIL_FS}/src"
BUILDJAILOBJ_FS="${BUILDJAIL_FS}/obj"


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

SRC_SVNBRANCH=$(rdnzl_zfs_get_property_value "${BUILDJAILSRC_FS}" "${SVNBRANCHPROP}") || \
    { echo "Can not read SVNBRANCH from filesystem ${BUILDJAILSRC_FS}"; exit 1;}

BUILDJAILSRC_MNT=$(rdnzl_zfs_get_property_value "${BUILDJAILSRC_FS}" "mountpoint")

OBJ_SVNREVISION=$(rdnzl_zfs_get_property_value "${BUILDJAILOBJ_FS}" "${SVNREVISIONPROP}") || \
    { echo "Can not read SVNREVISION from filesystem ${BUILDJAILOBJ_FS}"; exit 1;}

OBJ_SVNBRANCH=$(rdnzl_zfs_get_property_value "${BUILDJAILOBJ_FS}" "${SVNBRANCHPROP}") || \
    { echo "Can not read SVNBRANCH from filesystem ${BUILDJAILOBJ_FS}"; exit 1;}

BUILDJAILOBJ_MNT=$(rdnzl_zfs_get_property_value "${BUILDJAILOBJ_FS}" "mountpoint")

# Require that the SVN revisions of sources and objects match

if test "${OBJ_SVNREVISION}" -lt "${SRC_SVNREVISION}"; then
    echo "OBJ_SVNREVISION is lesser than SRC_SVNREVISION."
    echo "Have buildworld and buildkernel been run in the buildjail yet?"
    exit 1
fi



ROOT_DATASET=$(rdnzl_zfs_filesystem_from_path "/")

echo "ROOT_DATASET: ${ROOT_DATASET}"


# Read the SVN revisions of installed kernel and world. If the ZFS user properties
# are not present the revision should be interpreted as 0 (TODO). 

KERNEL_SVNREVISION=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${KERNELSVNREVISIONPROP}")
KERNEL_SVNBRANCH=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${KERNELSVNBRANCHPROP}")
WORLD_SVNREVISION=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${SVNREVISIONPROP}")
WORLD_SVNBRANCH=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${SVNBRANCHPROP}")

echo "KERNEL_SVNREVISION: ${KERNEL_SVNREVISION}"
echo "KERNEL_SVNBRANCH: ${KERNEL_SVNBRANCH}"
echo "WORLD_SVNREVISION: ${WORLD_SVNREVISION}"
echo "WORLD_SVNBRANCH: ${WORLD_SVNBRANCH}"
echo "OBJ_SVNREVISION: ${OBJ_SVNREVISION}"
echo "OBJ_SVNBRANCH: ${OBJ_SVNBRANCH}"


# Note: Installing sources/objects with the same SVNBRANCH/SVNREVISION is
# ok because sometimes it's necessary to redo a build using the same version.

# Mount /usr/src and /usr/obj if needed
if ! /sbin/mount | grep -q 'on /usr/src'; then
    /sbin/mount_nullfs "${BUILDJAILSRC_MNT}" /usr/src
fi   

if ! /sbin/mount | grep -q 'on /usr/obj'; then
    /sbin/mount_nullfs "${BUILDJAILOBJ_MNT}" /usr/obj
fi   

if test "${INSTALL_MODE}" = "kernel"; then 
    echo "Going to perform 'make installkernel' in /usr/src to install the new kernel."

    # TODO: Find a way to revert /boot/kernel* to initial state
    # if 'make installkernel' fails midway.

    # Run 'make installkernel'
    /usr/bin/make -C /usr/src installkernel || \
        { echo "'make installkernel' failed"; exit 1; }

    # Record the revision of the newly installed kernel to ZFS user property.
    "${ZFS_CMD}" set "${KERNELSVNREVISIONPROP}=${OBJ_SVNREVISION}" "${ROOT_DATASET}"

    # Branch as well in case it got changed
    "${ZFS_CMD}" set "${KERNELSVNBRANCHPROP}=${OBJ_SVNBRANCH}" "${ROOT_DATASET}"

    # Acknowledge that the kernel got installed
    echo "Installed kernel from build that was done with sources of"
    echo "branch ${OBJ_SVNBRANCH} and SVN revision ${OBJ_SVNREVISION}."
    echo "Restart to single user mode to continue update."
    
else 

    # Run the installworld sequence
    /usr/sbin/mergemaster -p

    /usr/bin/make -C /usr/src installworld

    /usr/sbin/mergemaster

    /usr/bin/make -C /usr/src -D BATCH_DELETE_OLD_FILES delete-old delete-old-libs

    # Record the revision of the newly installed world to ZFS user property.
    "${ZFS_CMD}" set "${SVNREVISIONPROP}=${OBJ_SVNREVISION}" "${ROOT_DATASET}"
    # And branch
    "${ZFS_CMD}" set "${SVNBRANCHPROP}=${OBJ_SVNBRANCH}" "${ROOT_DATASET}"

    echo "Installed world from build that was done with branch ${OBJ_SVNBRANCH} and SVN revision ${OBJ_SVNREVISION}"

fi

exit 0
