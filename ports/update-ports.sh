#!/bin/sh

# Script for updating the ports tree.

POUDRIERE=/usr/local/bin/poudriere

FLOCK=/usr/local/bin/flock

: ${PORTS_TREE:="default"}

while getopts "cp:" o
do
    case "$o" in 
    c)  CRONMODE=y;;  
    p)  PORTS_TREE=$OPTARG;;
    esac
done

echo "$0 starting at $(/bin/date '+%d.%m.%Y %H:%M:%S')"

# Delay for up to 1200 seconds before continuing in cron mode.

if [ -n "${CRONMODE}" ]; then
    sleep `jot -r 1 0 1200`
fi

exec 9>/var/db/rdnzl-admin/ports.lock

if ! ${FLOCK} -n 9  ; then
    echo "Ports tree locked, aborting.";
    exit 1
fi


PORTS_TREE_PATH=`${POUDRIERE} ports -lq | grep "^${PORTS_TREE}" | (read name method date time path; echo $path)`

cat <<EOT

Updating the ports tree "${PORTS_TREE}" at "${PORTS_TREE_PATH}"
---------------------------------------------------------------

EOT

$POUDRIERE ports -u -v -p "${PORTS_TREE}" || exit $?

echo "$0 done at $(/bin/date '+%d.%m.%Y %H:%M:%S')"

exit 0

