#!/bin/sh --


PKGNG=/usr/local/sbin/pkg 

${PKGNG} update


/usr/local/sbin/fetch-updating.sh

/usr/local/sbin/fetch-audit.sh


/usr/local/sbin/check-port-updates.sh

/usr/local/sbin/check-packages.sh





