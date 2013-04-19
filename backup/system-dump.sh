#!/bin/sh --


BACKUPHOST=beat.rdnzl.info

BACKUPPATH=/Volumes/Backup

TIMESTAMP=$( /bin/date "+%Y-%m-%d_%R:00" )

/sbin/dump -C16 -b64 -0uanL -h0 -f - /    | /usr/bin/gzip -2 | /usr/bin/ssh -c blowfish kimmo@${BACKUPHOST} dd of=${BACKUPPATH}/${HOST}-root.dump.${TIMESTAMP}.gz
