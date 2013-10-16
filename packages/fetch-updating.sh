#!/bin/sh --



FETCH=/usr/bin/fetch

UPDATING_URL=http://freebsd10.rdnzl.info/ports/UPDATING

cat <<EOT

Fetching a new UPDATING file
---------------------------------------------------------
EOT

${FETCH} -o /var/db/pkg/UPDATING ${UPDATING_URL}

exit 0
