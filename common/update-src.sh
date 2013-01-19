#!/bin/sh


SRC_DIR=/usr/src

GIT=/usr/local/bin/git

while getopts ciu o
do
    case "$o" in 
    c)  CRONMODE=y;;  
    esac

done

if [ -n "${CRONMODE}" ]; then
    sleep `jot -r 1 0 1200`
fi

cd ${SRC_DIR} && ${GIT} fetch -v

if [ -z "${CRONMODE}" ]; then
    cd ${SRC_DIR} && ${GIT} merge -v FETCH_HEAD
fi

echo "$0 done."
exit 0

