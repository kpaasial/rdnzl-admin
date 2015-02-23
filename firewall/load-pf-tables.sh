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


        #while read PREFIX
        #do
        /sbin/pfctl -T add -t "${TABLE}" -f "${TABLEFILE}"


        #done < "${TABLEFILE}"


    fi
done < "${CONFIG}"

