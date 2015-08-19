#!/bin/sh --

# Script for loading a set of IP/CIDR tables into pf(4)


# TODO: Check that PF is enabled before trying to load the tables into it.
# TODO: Also check that the tables exist in the ruleset.


: ${PFTABLES_CONFIG:="/opt/etc/pf-tables.conf"}
: ${PFTABLES_DBDIR:="/var/db/pf-tables"}

PFCTL=/sbin/pfctl

if [ ! -r "${PFTABLES_CONFIG}" ]; then
    echo "ERROR: config file ${PFTABLES_CONFIG} is not readable."
    exit 1
fi

if [ ! -d "${PFTABLES_DBDIR}" ]; then
    echo "ERROR: database directory ${PFTABLES_DBDIR} does not exist."
    exit 1
fi



while read line
do
    line="${line%%#*}"

    if [ -z "${line}" ]; then
        continue
    fi

    set -- $line

    URL=$1
    TABLE=$2

    if [ -z "${URL}" ] || [ -z "${TABLE}" ]; then
        echo "Malformed line ${line} in config file ${PFTABLES_CONFIG}"
        exit 1
    fi

    TABLEFILEPATH="${PFTABLES_DBDIR}/${TABLE}.txt"
    
    if [ -r "${TABLEFILEPATH}" ]; then 
        ${PFCTL} -T flush -t "${TABLE}"
        ${PFCTL} -T add -t "${TABLE}" -f "${TABLEFILEPATH}"
    else
        echo "ERROR: table file ${TABLEFILEPATH} not readable."
        exit 1
    fi
        
done < "${PFTABLES_CONFIG}"

