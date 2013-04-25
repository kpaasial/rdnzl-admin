#!/bin/sh

# Script for updating the ports tree.

SVN=/usr/local/bin/svn

: ${PORTS_DIR:="/usr/ports"}

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


[ -d $PORTS_DIR ]  && $SVN up $PORTS_DIR

cd $PORTS_DIR && make fetchindex

echo "$0 done."

exit 0

