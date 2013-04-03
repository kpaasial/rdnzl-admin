#!/bin/sh

PORTSTXT=$1
BUILD_JAIL=$2

: ${PORTSTXT:="/usr/local/etc/ports.txt"}
: ${BUILD_JAIL:="release91amd64"}



echo "Using ${PORTSTXT} as the list for ports to build."
echo "Using ${BUILD_JAIL} as the build jail."


/usr/local/bin/poudriere bulk -f ${PORTSTXT} -j ${BUILD_JAIL}


