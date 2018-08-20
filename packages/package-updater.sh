#!/bin/sh --

# Script for checking UPDATING and audit DB entries for
# installed packages. New UPDATING and audit DB files are downloaded.

PKG=/usr/local/sbin/pkg 

SVN_CMD=$(which svn 2>/dev/null || which svnlite 2>/dev/null)

INSTALL=/usr/bin/install

UPDATING_URL=https://svn.freebsd.org/ports/head/UPDATING

UPDATING_DB_PATH=/var/db/rdnzl-admin

# Fetch updated repository catalogues
${PKG} update -f

# Fetch new UPDATING file and show
# matching entries for installed packages

cat <<EOT

Fetching a new UPDATING file
---------------------------------------------------------
EOT

${INSTALL} -d -o root -g wheel ${UPDATING_DB_PATH}
${SVN_CMD} export --force ${UPDATING_URL} ${UPDATING_DB_PATH}/UPDATING

cat <<EOT

UPDATING entries for installed packages for the last month.
-----------------------------------------------------------
EOT

${PKG} updating -f ${UPDATING_DB_PATH}/UPDATING -d $(/bin/date -j -v -1m +%Y%m%d) 


# Update pkg-audit(8) database and show warnings
# about currently installed packages

cat <<EOT

Security vulnerabilities in installed packages.
-----------------------------------------------
EOT

${PKG} audit -F

# Check for updated packages 

cat <<EOT

Out of date packages.
---------------------

EOT

${PKG} version -RUvL '='

