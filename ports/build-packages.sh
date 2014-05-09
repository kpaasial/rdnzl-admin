#!/bin/sh

FLOCK=/usr/local/bin/flock


: ${RDNZL_CONFIG:="/usr/local/etc/rdnzl-admin/rdnzl.conf"}


if [ -f ${RDNZL_CONFIG} ]; then
    . ${RDNZL_CONFIG}
else
    echo "Configuration file ${RDNZL_CONFIG} missing."
    exit 1
fi


while getopts "f:j:p:" o
do
    case "$o" in
    f)  PORTS_TXT="$OPTARG";;
    j)  BUILD_JAIL="$OPTARG";;
    p)  PORTS_TREE="$OPTARG";;
    esac

done

shift $((OPTIND-1))


exec 9>/var/db/rdnzl-admin/ports.lock

if ! ${FLOCK} -n 9  ; then
    echo "Ports tree locked, aborting.";
    exit 1
fi


echo "Using ${PORTS_TXT} as the list for ports to build."
echo "Using ${BUILD_JAIL} as the build jail."
echo "Using ${PORTS_TREE} as the ports tree."

/usr/local/bin/poudriere bulk -f ${PORTS_TXT} -j ${BUILD_JAIL} -p ${PORTS_TREE} 


