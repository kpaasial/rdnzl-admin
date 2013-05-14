#!/bin/sh

# Script for updating the ports tree, checking for updated packages,
# pkg-audit(8) and UPDATING


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

/usr/local/sbin/update-ports.sh

/usr/local/sbin/check-port-updates.sh

/usr/local/sbin/check-packages.sh

echo "$0 done."

exit 0

