#!/bin/sh --

# Script for checking vulnerabilities with pkg-audit(8) and
# other checks for installed packages.

# This does not need the ports tree at /usr/ports.
# Can be run as non-root, the fetch scripts are separate.

PKGNG=/usr/local/sbin/pkg



cat <<EOT
Checking for vulnerable packages.
---------------------------------
EOT

${PKGNG} audit -x

cat <<EOT

Checking package dependencies
--------------------------------------
EOT

${PKGNG} check -dn


cat <<EOT

Checking package checksums
--------------------------------------
EOT

${PKGNG} check -sn 

cat <<EOT

Automatically added packages that are no longer depended on.
Run '${PKGNG} autoremove' to remove them.
--------------------------------------
EOT

${PKGNG} query -e '%a=1 && %#r=0' '%n-%v' || exit 1

exit 0

