#!/bin/sh

PORTSTXT=$1

: ${PORTSTXT:="/root/db/ports.txt"}
: ${SU_CMD:="/usr/bin/su root -c"}

echo "Using ${PORTSTXT} as the list for ports to build."

${SU_CMD} "/usr/local/bin/poudriere bulk -f ${PORTSTXT} -j release91amd64"


