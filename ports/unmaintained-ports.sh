#!/bin/sh --

POUDRIERE="/usr/local/bin/poudriere"

PORTS_TREE="default"
PORTS_TREE_PATH=`${POUDRIERE} ports -lq | grep "^${PORTS_TREE}" | (read name method date time path; echo $path)`

/usr/bin/find "${PORTS_TREE_PATH}" -mindepth 3 -maxdepth 3 -type f -name Makefile -exec egrep -li '^MAINTAINER.*ports@freebsd.org' {} \+ | \
    sed -e "s|^${PORTS_TREE_PATH}/\(.*/.*\)/Makefile|\1|g"  | /usr/bin/sort
