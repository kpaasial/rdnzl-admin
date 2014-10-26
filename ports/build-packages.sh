#!/bin/sh

usage()
{
    echo "$0 [-f portsfile] [-j jail] [-p portstree]"
    exit 0
}


FLOCK=/usr/local/bin/flock

: ${RDNZL_CONFIG:="/opt/etc/rdnzl-admin/rdnzl.conf"}


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

if ! ${FLOCK} -n 9  ; then
    echo "Ports tree locked, aborting.";
    exit 1
fi


echo "Using ${PORTS_TXT} as the list for ports to build."
echo "Using ${BUILD_JAIL} as the build jail."
echo "Using ${PORTS_TREE} as the ports tree."

/usr/local/bin/poudriere bulk -f ${PORTS_TXT} -j ${BUILD_JAIL} -p ${PORTS_TREE} 


