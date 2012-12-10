#!/bin/sh

PORTSTXT=$1

: ${PORTSTXT:="/usr/local/etc/ports.txt"}


echo "Using ${PORTSTXT} as the list for ports to build."

/usr/local/bin/poudriere bulk -f ${PORTSTXT} -j release91amd64


