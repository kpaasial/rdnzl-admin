#!/bin/sh

# Script for updating the ports tree, checking for updated packages,
# pkg-audit(8) and UPDATING


while getopts c o
do
    case "$o" in 
    c)  CRONMODE=y;;  
    esac

done



echo "$0 starting at $(/bin/date '+%d.%m.%Y %H:%M:%S')"

# Delay for up to 1200 seconds before continuing in cron mode.

if [ -n "${CRONMODE}" ]; then
    sleep `jot -r 1 0 1200`
fi

/usr/local/sbin/update-ports.sh


echo "$0 done at $(/bin/date '+%d.%m.%Y %H:%M:%S')"

exit 0

