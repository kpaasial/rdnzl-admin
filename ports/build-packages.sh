#!/bin/sh

FLOCK=/usr/local/bin/flock

: ${PORTSTXT:="/usr/local/etc/ports.txt"}
: ${BUILD_JAIL:="release10_0_i386"}


while getopts f:j: o
do
    case "$o" in
    f)  PORTSTXT="$OPTARG";;
    j)  BUILD_JAIL="$OPTARG";;
    esac

done

shift $((OPTIND-1))


exec 9>/var/db/rdnzl-admin/ports.lock

if ! ${FLOCK} -n 9  ; then
    echo "Ports tree locked, aborting.";
    exit 1
fi


echo "Using ${PORTSTXT} as the list for ports to build."
echo "Using ${BUILD_JAIL} as the build jail."


/usr/local/bin/poudriere bulk -f ${PORTSTXT} -j ${BUILD_JAIL} 


