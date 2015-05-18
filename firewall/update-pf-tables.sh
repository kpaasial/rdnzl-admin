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
    case "${SCRATCH}/" in 
        /tmp/pftables.${TEMPLATE}.*) /bin/rm -rf "${SCRATCH}";;
        *)      echo "Unexpected value for SCRATCH: ${SCRATCH}";;
    esac 
}

trap finish EXIT


echo "SCRATCH: ${SCRATCH}"


# Make two passes over the config file.
# First pass downloads the files and processes the input to strip comments.
while read URL TABLEFILE TABLE
do
    if [ -n "${URL}" ] && [ -n "${TABLEFILE}" ] && [ -n "${TABLE}" ]; then
        echo "URL: ${URL}"
        echo "TABLEFILE: ${TABLEFILE}"

        TMPFILE="${SCRATCH}/${TABLEFILE}"
        echo "TMPFILE: ${TMPFILE}"
        /usr/bin/fetch -a -T30 -o "${TMPFILE}" "${URL}" || exit 1

        # Process the downloaded file in-place. The sed(1) magic tries to 
        # strip all # and ; comments and then remove empty lines.
        if [ -r "${TMPFILE}" ]; then
            sed -e 's/[;#].*$//g' -e '/^\s*$/d' -i .bak "${TMPFILE}"
        else
            echo "ERROR: Temporary file ${TMPFILE} does not exist."
            exit 1
        fi
    fi
done < ${CONFIG}


# The second pass copies the temporary tables files to DBDIR.
# This is to avoid a situation where there is an error with one or more of the
# downloaded tables and the resulting tables are not consistent.

while read URL TABLEFILE TABLE
do
    if [ -n "${URL}" ] && [ -n "${TABLEFILE}" ] && [ -n "${TABLE}" ]; then
        echo "TABLEFILE: ${TABLEFILE}"

        TMPFILE="${SCRATCH}/${TABLEFILE}"
        echo "TMPFILE: ${TMPFILE}"

        if [ ! -r "${TMPFILE}" ]; then
            echo "ERROR: Temporary file ${TMPFILE} not readable."
            exit 1
        fi
        # Make a backup of the existing tablefile. This script will not restore
        # the backup in case of errors though.
        if [ -r "${DBDIR}/${TABLEFILE}" ]; then
            cp -f "${DBDIR}/${TABLEFILE}" "${DBDIR}/${TABLEFILE}.bak" || exit 1
        fi
        
        cp -f "${TMPFILE}" "${DBDIR}/${TABLEFILE}"
    fi
done < ${CONFIG}

