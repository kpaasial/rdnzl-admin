#!/bin/sh --

# Script for loading a set of IP/CIDR tables into pf(4)

CONFIG=/opt/etc/pf-tables.txt
DBDIR=/var/db/pf-tables


if [ ! -r "${CONFIG}" ]; then
    echo "ERROR: config file ${CONFIG} not readable."
    exit 1
fi

if [ ! -d "${DBDIR}" ]; then
    echo "ERROR: database directory ${DBDIR} does not exist."
    exit 1
fi

while read URL TABLEFILE TABLE
do
    if [ -n "${URL}" ] && [ -n "${TABLEFILE}" ] && [ -n "${TABLE}" ]; then
        TABLEFILE="${DBDIR}/${TABLEFILE}"
        echo "TABLEFILE: ${TABLEFILE}"
        echo "TABLE: ${TABLE}"
    
        if [ -r "${TABLEFILE}" ]; then 
            /sbin/pfctl -T flush -t "${TABLE}"
            /sbin/pfctl -T add -t "${TABLE}" -f "${TABLEFILE}"
        else
            echo "ERROR: table file ${TABLEFILE} not readable."
            exit 1
        fi
        
    fi
done < "${CONFIG}"

