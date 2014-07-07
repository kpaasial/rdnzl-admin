#!/bin/sh --

POUDRIERE="/usr/local/bin/poudriere"

PORTS_TREE="default"
PORTS_TREE_PATH=`${POUDRIERE} ports -lq | grep "^${PORTS_TREE}" | (read name method date time path; echo $path)`

/usr/bin/grep --include="${PORTS_TREE_PATH}/*/*/Makefile" -lr "^NO_STAGE" "${PORTS_TREE_PATH}" | \
    sed -e "s|^${PORTS_TREE_PATH}/\(.*/.*\)/Makefile|\1|g"  | /usr/bin/sort
