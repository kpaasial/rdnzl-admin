#!/bin/sh --

# Script for checking vulnerabilities with pkg-audit(8) and
# other checks for installed packages.

# This does not need the ports tree at /usr/ports.

PKGNG=/usr/local/sbin/pkg


if [ `id -u` -ne 0 ]; then
    echo "Please run $0 as root."
    exit 1
fi

cat <<EOT
Updating audit database and checking for vulnerable packages.
-------------------------------------------------------------
EOT

/usr/local/etc/periodic/security/410.pkg-audit


cat <<EOT

Checking package dependencies
--------------------------------------
EOT

${PKGNG} check -d 


cat <<EOT

Checking package checksums
--------------------------------------
EOT

${PKGNG} check -s 

cat <<EOT

Automatically added packages that are no longer depended on.
Run '${PKGNG} autoremove' to remove them.
--------------------------------------
EOT

${PKGNG} query -e '%a=1 && %#r=0' '%n-%v' || exit 1


