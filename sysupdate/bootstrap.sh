#!/bin/sh


# Script for bootstrapping a buildjail

# Creates a ZFS filesystem for the jail. Optionally downloads and installs a
# distribution set from ftp.freebsd.org into the new jail. Does the
# initial set up of the jail so it is ready to be started.

# Sets up the SVNREVISION and SVNBRANCH properties for the jail filesystem.

# Does not set up /etc/jail.conf entry for the jail but can output usable
# skeleton entry for it.


PREFIX="@@PREFIX@@"
SHARE_RDNZL="${PREFIX}/share/rdnzl"

. "${SHARE_RDNZL}/rdnzl-zfs-functions.sh"
. "${SHARE_RDNZL}/rdnzl-svn-functions.sh"
. "${PREFIX}/etc/rdnzl-admin/sysupdate-setup.rc"

usage()
{
    echo "$0 [-h] -a arch -B buildjail -b svnbranch" 
    exit 0
}

# Defaults for settings
# TODO: These should have no defaults but be required arguments.
#: ${BUILDJAIL:="buildstable10amd64"}

#: ${JAIL_SVNBRANCH:="stable/10"}



# Parse command line arguments to override the defaults.

while getopts "a:B:b:h" o
do
    case "$o" in
    a)  JAIL_ARCH="$OPTARG";;
    B)  BUILDJAIL="$OPTARG";;
    b)  JAIL_SVNBRANCH="$OPTARG";;
    h)  usage;;
    *)  usage;;
    esac
done

shift $((OPTIND-1))

if test -z "${JAIL_ARCH}" || test -z "${BUILDJAIL}" || test -z "${JAIL_SVNBRANCH}"; then
    usage
fi
