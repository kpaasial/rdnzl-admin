#!/bin/sh

# Script for updating the ports tree.

POUDRIERE=/usr/local/bin/poudriere

: ${PORTS_TREE:="default"}

while getopts c o
do
    case "$o" in 
    c)  CRONMODE=y;;  
    esac
done

# Delay for up to 1200 seconds before continuing in cron mode.

if [ -n "${CRONMODE}" ]; then
    sleep `jot -r 1 0 1200`
fi



PORTS_TREE_PATH=`${POUDRIERE} ports -lq -p ${PORTS_TREE} | (read name method path; echo $path)`


cat <<EOT

Updating the ports tree "${PORTS_TREE}" at "${PORTS_TREE_PATH}"
---------------------------------------------------------------

EOT


$POUDRIERE ports -u -v -p "${PORTS_TREE}"

cd ${PORTS_TREE_PATH} && make index

exit 0

