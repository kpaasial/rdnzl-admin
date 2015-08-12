#!/bin/sh --

# Script for updating a set of IP/CIDR tables.i
# This script does only the updating.

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

TEMPLATE="XXXXXXXXXX"

SCRATCH=$(/usr/bin/mktemp -d -t pftables.${TEMPLATE})

finish() {
    # Make sure we are deleting a temporary directory created by this script
    # and not something else. This script will be run as root, better safe than
    # sorry.  
    if echo "${SCRATCH}" | /usr/bin/egrep -q '^/tmp/pftables\..*'; then
         /bin/rm -rf "${SCRATCH}"
    else
        echo "Unexpected value for SCRATCH: ${SCRATCH}"
    fi     
}

trap finish EXIT


# Make two passes over the config file.
# First pass downloads the files into the SCRATCH directory.
# Any error in the downloads aborts the script.
while read URL TABLEFILE TABLE
do
    if [ -n "${URL}" ] && [ -n "${TABLEFILE}" ] && [ -n "${TABLE}" ]; then
        TMPFILE="${SCRATCH}/${TABLEFILE}"
        /usr/local/bin/curl -o "${TMPFILE}" "${URL}" || exit 1
    fi
done < ${CONFIG}


# The second pass strips comments from the downloaded files
# and places the results to DBDIR.

while read URL TABLEFILE TABLE
do
    if [ -n "${URL}" ] && [ -n "${TABLEFILE}" ] && [ -n "${TABLE}" ]; then

        TMPFILE="${SCRATCH}/${TABLEFILE}"

        if [ ! -r "${TMPFILE}" ]; then
            echo "ERROR: Temporary file ${TMPFILE} not readable."
            exit 1
        fi
        # Make a backup of the existing tablefile. This script will not restore
        # the backup in case of errors though.
        if [ -r "${DBDIR}/${TABLEFILE}" ]; then
            cp -f "${DBDIR}/${TABLEFILE}" "${DBDIR}/${TABLEFILE}.bak" || exit 1
        fi
        
        if [ -r "${TMPFILE}" ]; then
            sed -e 's/[;#].*$//g' -e '/^\s*$/d' "${TMPFILE}" >"${DBDIR}/${TABLEFILE}"
        else
            echo "ERROR: Temporary file ${TMPFILE} does not exist."
            exit 1
        fi
    fi
done < ${CONFIG}

