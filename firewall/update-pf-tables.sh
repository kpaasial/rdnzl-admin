#!/bin/sh --

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

while read URL TABLEFILE TABLE
do
    if [ -n "${URL}" ] && [ -n "${TABLEFILE}" ] && [ -n "${TABLE}" ]; then
        echo "URL: ${URL}"
        echo "TABLEFILE: ${TABLEFILE}"

        TMPFILE="${SCRATCH}/${TABLEFILE}"
        echo "TMPFILE: ${TMPFILE}"
        /usr/bin/fetch -a -T30 -o "${TMPFILE}" "${URL}" || exit 1

        # Make a backup of the existing tablefile. This script will not restore
        # the back up in case of errors though.
        if [ -r "${DBDIR}/${TABLEFILE}" ]; then
            cp "${DBDIR}/${TABLEFILE}" "${DBDIR}/${TABLEFILE}.bak" || exit 1
        fi
        # Process the downloaded file if it exists and put the final version
        # under DBDIR. The sed(1) magic tries to strip all # and ; comments
        # and then remove empty lines.
        if [ -r "${TMPFILE}" ]; then
            sed -e 's/[;#].*$//g' -e '/^\s*$/d' "${TMPFILE}"  >"${DBDIR}/${TABLEFILE}"
        fi
    fi
done < ${CONFIG}

/opt/sbin/load-pf-tables.sh

