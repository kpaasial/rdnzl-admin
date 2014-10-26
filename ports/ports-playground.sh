#!/bin/sh --



usage() {
    echo "usage: $0 [-f]" >&2
    exit 1
}

POUDRIERE=/usr/local/bin/poudriere

: ${POUDRIERE_PORTS_TREE:="default"}
: ${DEFAULT_PORTS_DIR:="/usr/ports"}

# Where to create the cloned ZFS dataset
: ${CLONEFS:="rdnzltank/DATA/ports"}

while getopts "fhp:" o
do
    case "$o" in
    f)  FORCE_MODE=1;;  
    h)  usage;;
    p)  PORTS_TREE=$OPTARG;;
    *)  usage;;
    esac
done

PORTS_DIR_PATH=`${POUDRIERE} ports -lq | grep "^${POUDRIERE_PORTS_TREE}" | (read name method date time path; echo $path)`
PORTS_DIR_FS=`/sbin/zfs list -o name -H ${PORTS_DIR_PATH}`

cd "${PORTS_DIR_PATH}" || (echo "No ${PORTS_DIR_PATH} directory?" && exit 1)

test -f Makefile || (echo "Empty ports directory ${PORTS_DIR_PATH}?" && exit 1)

: ${SVN_CMD:=$(which svn 2>/dev/null || which svnlite 2>/dev/null)}
: ${SVNVERSION_CMD:=$(which svnversion 2>/dev/null || which svnliteversion 2>/dev/null)}


SVNVERSION="$(${SVN_CMD} info . | awk '/^Revision:/ {print $2}')"

BRANCH=$(${SVN_CMD} info . | awk '/^Relative URL:/ {sub(/\^\//,"", $3); print $3}')


echo "SVNVERSION: $SVNVERSION"
echo "BRANCH: $BRANCH"

echo "PORTS_DIR_PATH: ${PORTS_DIR_PATH}"
echo "PORTS_DIR_FS: ${PORTS_DIR_FS}"


# Test if there is already a snapshot $PORTS_DIR_FS@$SVNVERSION
# Require force mode to overwrite it
if test -z ${FORCE_MODE} && /sbin/zfs list -H -o name "${PORTS_DIR_FS}@${SVNVERSION}" >/dev/null 2>&1 ; then
    echo "Snapshot ${PORTS_DIR_FS}@${SVNVERSION} already exists, use -f to overwrite."
    exit 1
fi

# Test if there is already a (ZFS) filesystem at $DEFAULT_PORTS_DIR
# Tell user to unmount/destroy the offending FS first
if /sbin/mount | grep -q "on ${DEFAULT_PORTS_DIR} "; then
    echo "Something is already mounted on ${DEFAULT_PORTS_DIR}, umount it first"
    exit 1;
fi

# Remove the snapshot if it exists. The -f option is tested above so this can be always done.
if /sbin/zfs list -H -o name "${PORTS_DIR_FS}@${SVNVERSION}" >/dev/null 2>&1 ; then
    /sbin/zfs destroy "${PORTS_DIR_FS}@${SVNVERSION}"
fi

# Create the snapshot ${PORTS_DIR_FS}@${SVNVERSION}
/sbin/zfs snapshot "${PORTS_DIR_FS}@${SVNVERSION}"

# Create the clone from $PORTS_DIR_FS@$SVNVERSION with the mountpoint set to $DEFAULT_PORTS_DIR
/sbin/zfs clone -o mountpoint="${DEFAULT_PORTS_DIR}" "${PORTS_DIR_FS}@${SVNVERSION}" "${CLONEFS}"
