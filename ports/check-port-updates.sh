#!/bin/sh --

# Script for checking pkg-updating(8) for installed packages
# Can be run as non-root and does not need a ports tree.

PKGNG=/usr/local/sbin/pkg

cat <<EOT

UPDATING entries for installed packages for the last month
---------------------------------------------------------
EOT

${PKGNG} updating -f /var/db/pkg/UPDATING -d $(/bin/date -j -v -1m +%Y%m%d) 

cat <<EOT

Out of date packages.
---------------------

EOT

${PKGNG} version -RUvL '='

exit 0

