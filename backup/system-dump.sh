#!/bin/sh --


: ${HOST:=$(hostname)}

BACKUPPATH=/backup

TIMESTAMP=$( /bin/date "+%Y-%m-%d_%R:00" )


#/sbin/dump -C16 -b64 -0uanL -h0 -f - /data | /usr/bin/gzip -2 > ${BACKUPPATH}/${HOST}-data.dump.${TIMESTAMP}.gz

/sbin/dump -C16 -b64 -0uanL -h0 -f - / | /usr/bin/gzip -2 > ${BACKUPPATH}/${HOST}-root.dump.${TIMESTAMP}.gz
