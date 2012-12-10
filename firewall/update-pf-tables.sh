#!/bin/sh

CONFIG=/usr/local/etc/pf-tables.txt

while read URL TABLEFILE
do
    if [ -n "${URL}" ]; then
        echo "URL: ${URL}"
        echo "TABLEFILE: ${TABLEFILE}"


    TMPFILE=$(mktemp -t pf-tables$$) || exit 1
    fetch -T 30 -o "${TMPFILE}" "${URL}" || exit 1
    if [ -e "${TABLEFILE}" ]; then
        cp ${TABLEFILE} ${TABLEFILE}.bak || exit 1
        rm -f ${TABLEFILE} || exit 1
    fi
    sed -e '/^[ :space: ]*;/d' -e 's/\([0-9][/0-9.]*\) .*/\1/' ${TMPFILE} >${TABLEFILE}

    rm ${TMPFILE}
    fi
done < ${CONFIG}

/usr/sbin/service pf reload
