#!/bin/sh --

PKGNG=/usr/local/sbin/pkg

cat <<EOT

Fetching a new vulnxml file
---------------------------------------------------------
EOT

${PKGNG} audit -F

exit 0
