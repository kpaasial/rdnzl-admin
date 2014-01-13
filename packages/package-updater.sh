#!/bin/sh --


PKGNG=/usr/local/sbin/pkg 

# Fetch updated repository catalogues
${PKGNG} update

# Fetch new UPDATING file and show
# matching entries for installed packages
/usr/local/sbin/fetch-updating.sh

# Update pkg-audit(8) database and show warnings
# about currently installed packages
/usr/local/sbin/fetch-audit.sh

# Check for updated packages 

cat <<EOT

Out of date packages.
---------------------

EOT

${PKGNG} version -RUvL '='






