#!/bin/sh --

# Script for updating a set of IP/CIDR tables.
# This script does only the downloading and updating of the table files.

# TODO: do not hardcode paths to utilities. Detect them at run time.
# TODO: allow a mode that only downloads the files into the temporary directory
# for testing.

: ${PFTABLES_CONFIG:="/opt/etc/pf-tables.conf"}
: ${PFTABLES_DBDIR:="/var/db/pf-tables"}

CP=/bin/cp
FTP=/usr/bin/ftp
MKTEMP=/usr/bin/mktemp
PFCTL=/sbin/pfctl
RM=/bin/rm
SED=/usr/bin/sed


if [ ! -r "${PFTABLES_CONFIG}" ]; then
    echo "ERROR: config file ${PFTABLES_CONFIG} is not readable."
    exit 1
fi

if [ ! -d "${PFTABLES_DBDIR}" ]; then
    echo "ERROR: database directory ${PFTABLES_DBDIR} does not exist."
    exit 1
fi

TEMPLATE="XXXXXXXXXX"

SCRATCH=$(${MKTEMP} -d /tmp/pftables-${TEMPLATE})

finish() {
    # Make sure we are deleting a temporary directory created by this script
    # and not something else. This script will be run as root, better safe than
    # sorry. The trick here is to test if the pattern on the right side of ##
    # "eats" everything in $SCRATCH. Zero length result means a complete match. 
    if test -z "${SCRATCH##/tmp/pftables-??????????}" ; then
         ${RM} -rf "${SCRATCH}"
    else
        echo "Unexpected value for SCRATCH: ${SCRATCH}"
    fi     
}

trap finish EXIT


# Make three passes over the config file.
# First pass downloads the files into the $SCRATCH directory and removes
# comments. Any error in the downloads aborts the script and cleans up $SCRATCH.
# Second pass stores the downloaded files at $PFTABLES_DBDIR.
# Third pass loads the stored table files into PF.

# TODO: The configuration file could be validated more strictly here.
# Now there is only a test that it has two fields per line.

for mode in "download" "store" "load"; do

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

        TMPFILE="${SCRATCH}/${TABLE}"
        TABLEFILEPATH="${PFTABLES_DBDIR}/${TABLE}.txt"

        case "${mode}" in
            "download" )
                ${FTP} -o - "${URL}" | \
                    ${SED} -e 's/[;#].*$//g' -e '/^\s*$/d' > "${TMPFILE}" || exit 1
                ;;
            "store" )
                if [ ! -r "${TMPFILE}" ]; then
                    echo "ERROR: Temporary file ${TMPFILE} is not readable."
                    exit 1
                fi
        
                ${CP} "${TMPFILE}" "${TABLEFILEPATH}" || exit 1
                ;;
            "load" )
                if [ ! -r "${TABLEFILEPATH}" ]; then
                    echo "ERROR: table file ${TABLEFILEPATH} not readable."
                    exit 1
                fi
 
                ${PFCTL} -T flush -t "${TABLE}"
                ${PFCTL} -T add -t "${TABLE}" -f "${TABLEFILEPATH}"
                ;;
        esac
    done < ${PFTABLES_CONFIG}
done

exit 0
