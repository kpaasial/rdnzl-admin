#!/bin/sh

usage()
{
    echo "$0 [-f portsfile] [-j jail] [-p portstree]"
    exit 0
}

POUDRIERE_PATH=/usr/local/bin/poudriere
FLOCK_PATH=/usr/local/bin/flock


if [ -z "${RDNZL_CONFIG}" ]; then
    echo "RDNZL_CONFIG not set in environment, can not find configuration."
    exit 1
fi

if [ -f ${RDNZL_CONFIG} ]; then
    . ${RDNZL_CONFIG}
else
    echo "Configuration file ${RDNZL_CONFIG} missing."
    exit 1
fi


while getopts "f:hj:p:" o
do
    case "$o" in
    f)  PORTS_TXT="$OPTARG";;
    h)  usage;;
    j)  BUILD_JAIL="$OPTARG";;
    p)  PORTS_TREE="$OPTARG";;
    *)  usage;;
    esac

done

shift $((OPTIND-1))


exec 9>/var/db/rdnzl-admin/ports.lock

if ! ${FLOCK_PATH} -n 9  ; then
    echo "Ports tree locked, aborting.";
    exit 1
fi


echo "Using ${PORTS_TXT} as the list for ports to build."
echo "Using ${BUILD_JAIL} as the build jail."
echo "Using ${PORTS_TREE} as the ports tree."

${POUDRIERE_PATH} bulk -f ${PORTS_TXT} -j ${BUILD_JAIL} -p ${PORTS_TREE} 


