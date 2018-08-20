#!/bin/sh --


PKG=/usr/local/sbin/pkg



cat <<EOT
Checking for vulnerable packages.
---------------------------------
EOT

${PKG} audit || exit 1

cat <<EOT

Checking package dependencies
--------------------------------------
EOT

${PKG} check -dn || exit 1


cat <<EOT

Checking shared library dependencies
--------------------------------------
EOT

${PKG} check -Bn || exit 1

cat <<EOT

Checking package checksums
--------------------------------------
EOT

${PKG} check -sn || exit 1

cat <<EOT

Automatically added packages that are no longer depended on.
Run '${PKG} autoremove' to remove them.
--------------------------------------
EOT

${PKG} query -e '%a=1 && %#r=0' '%n-%v' || exit 1

exit 0

