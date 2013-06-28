#!/bin/sh

PKG_DBDIR="/var/db/pkg"
PKGNG="/usr/local/sbin/pkg"

find ${PKG_DBDIR} -type d -maxdepth 1 -mindepth 1 | cut -d / -f 5 | \
    while read pkg; do
        if ! ${PKGNG} info $pkg >/dev/null 2>&1; then
            rm -rv "${PKG_DBDIR}/$pkg"
        fi
    done
    
