#!/bin/sh

# Script for updating the host using the build(7) results
# from a buildjail.

# Two modes of operation.

# First mode runs the 'make installkernel' part of the update
# procedure. Also records the installed kernel version with 
# ZFS user properties on the root filesystem.

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
# TODO: Figure out a way to include these from
# ${PREFIX}/share/rdnzl without hardcoding PREFIX to scripts.
# Maybe take the path to the script from $0 and take dirname(1) of
# it (twice), then add /share/rdznl.

PREFIX=$(dirname $(dirname "$0") )

echo "PREFIX: ${PREFIX}"




. "${PREFIX}/rdnzl-zfs-functions.sh"
. "${PREFIX}/rdnzl-svn-functions.sh"
. "${PREFIX}/rdnzl-jailtools-setup.sh"


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

# Read the SVN revision of the sources

SRC_FS="${SRC_BASEFS}/${BRANCH}/${BRANCHVERSION}"

SRC_PATH=$(rdnzl_zfs_get_property_value "${SRC_FS}" mountpoint) || \
    { echo "No sources exist for ${BRANCH}/${BRANCHVERSION}"; exit 1;}

# SVN revision of the source tree
SVNREVISION=$(rdnzl_svn_get_revision "${SRC_PATH}") || \
    { echo "Can't get SVN revision for ${SRC_PATH}"; exit 1;}

BRANCHOFSOURCES=$(rdnzl_svn_get_branch "${SRC_PATH}") || \
    { echo "Can't get SVN branch for ${SRC_PATH}"; exit 1;}


# TODO: Record the SVN revision of the finished build into
# ${BUILDJAILFS}/obj. Use the recorded revision to detect if
# the objects have already been used with 'make installkernel'
# and 'make installworld'


# TODO: This could actually use the bootfs property of
# of the pool
ROOT_DATASET=$(rdnzl_zfs_filesystem_from_path "/")

echo "ROOT_DATASET: ${ROOT_DATASET}"


# Read the SVN revision of the installed kernel. If the ZFS user properties
# are not present the revision is interpreted as 0. 

INSTALLED_KERNEL_REVISION=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${KERNELREVPROP}")
INSTALLED_KERNEL_BRANCH=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${KERNELBRANCHPROP}")
INSTALLED_WORLD_REVISION=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${WORLDREVPROP}")
INSTALLED_WORLD_BRANCH=$(rdnzl_zfs_get_property_value "${ROOT_DATASET}" "${WORLDBRANCHPROP}")

echo "INSTALLED_KERNEL_REVISION: ${INSTALLED_KERNEL_REVISION}"
echo "INSTALLED_KERNEL_BRANCH: ${INSTALLED_KERNEL_BRANCH}"
echo "INSTALLED_WORLD_REVISION: ${INSTALLED_WORLD_REVISION}"
echo "INSTALLED_WORLD_BRANCH: ${INSTALLED_WORLD_BRANCH}"
echo "SVNREVISION: ${SVNREVISION}"
echo "BRANCHOFSOURCES: ${BRANCHOFSOURCES}"


# Compare the SVN revisions of the sources and installed kernel.
# If the installed kernel revision is less than the revision of the
# sources perform 'make installkernel', record the new revision in
# ZFS user properties and exit. Instruct the user to shutdown and reboot
# to single user mode to continue the host update with the update of 
# world.

if test "${INSTALLED_KERNEL_REVISION}" -lt "${SVNREVISION}"; then
    echo "Going to perform 'make installkernel' in /usr/src to install the new kernel.""

    # Mount /usr/src and /usr/obj if needed

    # Run 'make installkernel'

    # Record the revision of the newly installed kernel to ZFS user property.

    # Acknowledge that the kernel got installed
    echo "Installed kernel from build that was done with sources of"
    echo "SVN revision ${SVNREVISION}."
    echo "Restart to single user mode to continue update."

    exit 0
fi 

exit 0

# If the version of the installed kernel matches the sources we are
# probably in single user mode being run after /upgrade.sh.
# (This won't be run before /upgrade.sh because this script may not
# be available until /upgrade.sh has mounted all filesystems).
# Record the svnrevision of the sources used as the version of the installed
# world on the root filesystem.
# TODO: Find a way to verify that the world was in fact updated to 
# SVNVERSION of the sources before this script is run.








