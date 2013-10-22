#!/bin/sh --


: ${HOST:=$(hostname)}

BACKUPPATH=/mnt

TIMESTAMP=$( /bin/date "+%Y-%m-%d_%R:00" )

/sbin/dump -C16 -b64 -0uanL -h0 -f - / | /usr/bin/gzip -2 > ${BACKUPPATH}/${HOST}-root.dump.${TIMESTAMP}.gz
