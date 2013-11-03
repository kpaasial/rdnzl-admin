#!/bin/sh --


PKGNG=/usr/local/sbin/pkg 

FETCH=/usr/bin/fetch

INSTALL=/usr/bin/install

UPDATING_URL=http://freebsd10.rdnzl.info/ports/UPDATING

UPDATING_DB_PATH=/var/db/rdnzl-admin



cat <<EOT

Fetching a new UPDATING file
---------------------------------------------------------
EOT

${INSTALL} -d -o root -g wheel ${UPDATING_DB_PATH}
${FETCH} -o ${UPDATING_DB_PATH}/UPDATING ${UPDATING_URL}

cat <<EOT

UPDATING entries for installed packages for the last month
---------------------------------------------------------
EOT

${PKGNG} updating -f ${UPDATING_DB_PATH}/UPDATING -d $(/bin/date -j -v -1m +%Y%m%d) 

exit 0
