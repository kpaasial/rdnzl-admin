#!/bin/sh


# Script that creates a ZFS clone jail(8) out of existing jail
# that is on a ZFS dataset. 

# In addition to the root filesystem the system sources that
# match the created clone jail in the SVN revision is mounted
# at /usr/src directory of the created clone jail. This is done
# By snapshotting and cloning the ZFS dataset with the system
# sources.


# Default dataset paths are:
# zfspool/DATA/jails/basejail - the jail to be cloned
# zfspool/DATA/jails/clonejail - the created clone from basejail
# zfspool/DATA/src/branch/version - the system sources


: ${SVN_CMD:=$(which svn 2>/dev/null || which svnlite 2>/dev/null)}

# Defaults for settings

: ${SRC_PATH:="/data/src"}

: ${BRANCH:="stable"}

: ${BRANCHVERSION:="10"}

: ${BASEJAIL:="buildstable10amd64"}

: ${CLONEJAIL:="clonestable10amd64"}

# Parse command line arguments to override the defaults.

while getopts "B:b:C:v:" o
do
    case "$o" in
    B)  BASEJAIL="$OPTARG";;
    b)  BRANCH="$OPTARG";;
    C)  CLONEJAIL="$OPTARG";;
    v)  BRANCHVERSION="$OPTARG";;
    *)  usage;;
    esac

done

shift $((OPTIND-1))


PATH_TO_SRC="${SRC_PATH}/${BRANCH}/${BRANCHVERSION}"

# SVN revision of the source tree
SVNREVISION="$(${SVN_CMD} info ${PATH_TO_SRC} | awk '/^Revision:/ {print $2}')"

BRANCHOFSOURCES=$(${SVN_CMD} info ${PATH_TO_SRC} | awk '/^Relative URL:/ {sub(/\^\//,"", $3); print $3}')

# Root dataset for the cloned jail
: ${CLONEJAILFS:="rdnzltank/DATA/jails/${CLONEJAIL}"}

# Dataset for the cloned src tree, created under
# ${CLONEJAILFS}.

: ${CLONESRCFS:="${CLONEJAILFS}/src-${BRANCH}-${BRANCHVERSION}-${SVNREVISION}"}


# Bit of debug output...

echo "BRANCHOFSOURCES: ${BRANCHOFSOURCES}"

echo "SVNREVISION: ${SVNREVISION}"

echo "CLONEJAILFS: ${CLONEJAILFS}"

echo  "CLONESRCFS: ${CLONESRCFS}"

exit 0

# First create a snapshot of the basejail dataset.
# The snapshot name is the SVN revision of the matching sources
# unless overridden.



# Then create the clone dataset.


# Then snapshot the system sources@SVNrevision


# Then deduce a name for the clone source dataset to be mounted at
# clonejail/usr/src. It should be unique for the cloned jail.
# Set the mountpoint of the created clone at clonejail/usr/src
