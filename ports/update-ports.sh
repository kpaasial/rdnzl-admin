#!/bin/sh

# Script for updating the ports tree.

POUDRIERE=/usr/local/bin/poudriere


PORTS_DIR=`poudriere ports -lq | grep ^default | (read name method portsdir; echo -n $portsdir)`

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

cat <<EOT

Updating the default ports tree at ${PORTS_DIR}
-------------------------------------

EOT

${POUDRIERE} ports -u -p default

echo "$0 done."

exit 0

