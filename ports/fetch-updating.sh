#!/bin/sh --



RSYNC=/usr/local/bin/rsync
PORTS_TREE=default


PORTS_TREE_PATH=$(poudriere ports -lq -p ${PORTS_TREE} | (read name method mnt; echo $mnt))

UPDATING_PATH="${PORTS_TREE_PATH}/UPDATING"


cat <<EOT

Fetching a new UPDATING file
---------------------------------------------------------
EOT

${RSYNC} -v ${UPDATING_PATH} /var/db/pkg/UPDATING

exit 0
