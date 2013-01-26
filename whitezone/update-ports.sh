#!/bin/sh

# Script for updating the ports tree.

PORTS_DIR=`poudriere ports -lq | grep ^default | (read name method portsdir; echo -n $portsdir)`
GIT=/usr/local/bin/git

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

Pulling updates for ${PORTS_DIR} with git(1).
-------------------------------------

EOT

cd ${PORTS_DIR} && ${GIT} fetch


if [ -n "${CRONMODE}" ]; then
    echo "$0 done."
    exit 0
fi 

cd ${PORTS_DIR} && ${GIT} merge FETCH_HEAD

echo "$0 done."

exit 0

