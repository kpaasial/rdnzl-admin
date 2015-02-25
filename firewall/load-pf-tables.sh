#!/bin/sh

CONFIG=/opt/etc/pf-tables.txt
DBDIR=/var/db/pf-tables


while read URL TABLEFILE TABLE
do
    if [ -n "${URL}" ]; then
        echo "URL: ${URL}"
        TABLEFILE="${DBDIR}/${TABLEFILE}"
        echo "TABLEFILE: ${TABLEFILE}"
        echo "TABLE: ${TABLE}"

        /sbin/pfctl -T flush -t "${TABLE}"
        /sbin/pfctl -T add -t "${TABLE}" -f "${TABLEFILE}"
    fi
done < "${CONFIG}"

