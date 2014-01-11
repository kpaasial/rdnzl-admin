#!/bin/sh --


PKGNG=/usr/local/sbin/pkg 

SVN=/usr/bin/svn

INSTALL=/usr/bin/install

UPDATING_URL=https://svn0.eu.freebsd.org/ports/head/UPDATING

UPDATING_DB_PATH=/var/db/rdnzl-admin



cat <<EOT

Fetching a new UPDATING file
---------------------------------------------------------
EOT

${INSTALL} -d -o root -g wheel ${UPDATING_DB_PATH}
${SVN} export --force ${UPDATING_URL} ${UPDATING_DB_PATH}/UPDATING

cat <<EOT

UPDATING entries for installed packages for the last month
---------------------------------------------------------
EOT

${PKGNG} updating -f ${UPDATING_DB_PATH}/UPDATING -d $(/bin/date -j -v -1m +%Y%m%d) 

exit 0
