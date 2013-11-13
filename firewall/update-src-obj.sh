#!/bin/sh --


RSYNC=/usr/local/bin/rsync



BUILD_HOST_URI=toor@freebsd10.rdnzl.info



${RSYNC} -avz --delete --delete-excluded --exclude='.svn*' ${BUILD_HOST_URI}:/usr/src/ /usr/src

${RSYNC} -avz --delete --delete-excluded --exclude='usr/src/release*' ${BUILD_HOST_URI}:/usr/obj/ /usr/obj


