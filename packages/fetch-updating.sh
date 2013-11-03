#!/bin/sh --


PKGNG=/usr/local/sbin/pkg 

FETCH=/usr/bin/fetch

UPDATING_URL=http://freebsd10.rdnzl.info/ports/UPDATING

cat <<EOT

Fetching a new UPDATING file
---------------------------------------------------------
EOT

${FETCH} -o /var/db/pkg/UPDATING ${UPDATING_URL}

cat <<EOT

UPDATING entries for installed packages for the last month
---------------------------------------------------------
EOT

${PKGNG} updating -f /var/db/pkg/UPDATING -d $(/bin/date -j -v -1m +%Y%m%d) 

exit 0
