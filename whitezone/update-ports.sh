#!/bin/sh

PKGNG=/usr/local/sbin/pkg



# parse options

while getopts ci o
do
    case "$o" in 
    c)  CRONMODE=y;;  
    i)  INITMODE=y;;
    esac

done



# If run in cron mode delay for up to 1800 seconds before continuing

if [ -n "$CRONMODE" ]; then
    sleep `jot -r 1 0 1800`
fi




cat <<EOT
Updating audit database and checking for vulnerable packages.
-------------------------------------------------------------
EOT

/usr/local/etc/periodic/security/410.pkg-audit


cat <<EOT

Updating /usr/ports with svn(1).
-------------------------------------

EOT


/usr/local/bin/svn up /usr/ports


# In init mode the cache is rebuilt from scratch
if [ -n "$INITMODE" ]; then
    /usr/local/bin/cache-init
else
    /usr/local/bin/cache-update
fi

/usr/local/bin/portindex -o /usr/ports/INDEX-9



cat <<EOT

Automatically added packages that are no longer depended on.
Run '${PKGNG} autoremove' to remove them.
--------------------------------------
EOT

${PKGNG} query -e '%a=1 && %#r=0' '%n-%v' || exit 1

cat <<EOT

Installed packages that have updates available:
-----------------------------------------------

EOT

${PKGNG} version -IvL=


UPD_START_DATE=$(/bin/date -v-1m +%Y%m%d)
cat <<EOT

Warnings from /usr/ports/UPDATING for installed packages
from ${UPD_START_DATE} to today.
---------------------------------------------------------
EOT

${PKGNG} updating -d ${UPD_START_DATE} || exit 1


