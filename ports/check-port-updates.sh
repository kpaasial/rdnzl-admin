#!/bin/sh --

# Script for checking pkg-updating(8) for installed packages
# and for out of date packages.

# Needs a port tree at /usr/ports.

PKGNG=/usr/local/sbin/pkg

cat <<EOT

UPDATING entries for installed packages for the last month
---------------------------------------------------------
EOT

${PKGNG} updating -d $(/bin/date -j -v -1m +%Y%m%d) 

cat <<EOT

Out of date packages.
---------------------

EOT

${PKGNG} version -vL '='

exit 0

