#!/bin/sh --


RSYNC=/usr/local/bin/rsync



BUILD_HOST_URI=toor@freebsd10.rdnzl.info



${RSYNC} -avz ${BUILD_HOST_URI}:/usr/src/ /usr/src

${RSYNC} -avz --exclude='usr/src/release/*' ${BUILD_HOST_URI}:/usr/obj/ /usr/obj


