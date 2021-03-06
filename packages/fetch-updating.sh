#!/bin/sh --


PKGNG=/usr/local/sbin/pkg 


: ${SVN_CMD:=$(which svn 2>/dev/null || which svnlite 2>/dev/null)}

INSTALL=/usr/bin/install

UPDATING_URL=https://svn.freebsd.org/ports/head/UPDATING

UPDATING_DB_PATH=/var/db/rdnzl-admin



cat <<EOT

Fetching a new UPDATING file
---------------------------------------------------------
EOT

${INSTALL} -d -o root -g wheel ${UPDATING_DB_PATH}
${SVN_CMD} export --force ${UPDATING_URL} ${UPDATING_DB_PATH}/UPDATING

cat <<EOT

UPDATING entries for installed packages for the last month
---------------------------------------------------------
EOT

${PKGNG} updating -f ${UPDATING_DB_PATH}/UPDATING -d $(/bin/date -j -v -1m +%Y%m%d) 

exit 0
