#!/bin/sh

# Script for updating the ports tree.

POUDRIERE=/usr/local/bin/poudriere


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

Updating the ports tree "default"
---------------------------------

EOT


$POUDRIERE ports -u -v

exit 0

