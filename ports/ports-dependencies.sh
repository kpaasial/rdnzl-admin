#!/bin/sh --



usage() {
    echo "usage: $0 [-h] [-a] [-b] [-p portsdir] [-r] origin" >&2
    exit 1
}

POUDRIERE=/usr/local/bin/poudriere

MAKE_CMD=/usr/bin/make

: ${POUDRIERE_PORTS_TREE:="default"}

: ${DEPENDENCIES:="build"}

while getopts "adh:p:r" o
do
    case "$o" in
    a)  DEPENDENCIES="all";;
    b)  DEPENDENCIES="build";;
    h)  usage;;
    p)  POUDRIERE_PORTS_TREE=$OPTARG;;
    r)  DEPENDENCIES="run";;
    *)  usage;;
    esac
done

shift $((OPTIND-1))

PORT_ORIGIN="$1"

if test -z "$PORT_ORIGIN"; then
    usage
fi

# Path to the ports(7) tree used by poudriere
PORTS_DIR_PATH=`${POUDRIERE} ports -lq | grep "^${POUDRIERE_PORTS_TREE}" | (read name method date time path; echo $path)`

# Set variables in env(1) for make(1) command
CMD_ENV="${CMD_ENV} PORTSDIR=${PORTS_DIR_PATH}"

# The directory for $PORT_ORIGIN
PORT_ORIGIN_PATH="${PORTS_DIR_PATH}/${PORT_ORIGIN}"

# The saved options directory that poudriere uses.
# TODO: Get this from poudriere and do not hardcode it.
POUDRIERE_PORT_DBDIR="/usr/local/etc/poudriere.d/options"

CMD_ENV="${CMD_ENV} PORT_DBDIR=${POUDRIERE_PORT_DBDIR}"

exec env -i ${CMD_ENV} "${MAKE_CMD}" -C "${PORT_ORIGIN_PATH}" "${DEPENDENCIES}-depends-list" | /usr/bin/sort -u

