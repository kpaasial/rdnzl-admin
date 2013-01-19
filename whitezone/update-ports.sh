#!/bin/sh

# Script for updating the ports tree.

PORTS_DIR=/usr/ports
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

Pulling updates for /usr/ports with git(1).
-------------------------------------

EOT

cd ${PORTS_DIR} && ${GIT} fetch -v


if [ -n "${CRONMODE}" ]; then
    echo "$0 done."
    exit 0
fi 

cd ${PORTS_DIR} && ${GIT} merge -v FETCH_HEAD

cat <<EOT

Creating INDEX.
-------------------------------------

EOT

make -C ${PORTS_DIR} index

echo "$0 done."

exit 0

