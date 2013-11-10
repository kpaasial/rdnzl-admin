#!/bin/sh --


RSYNC=/usr/local/bin/rsync



${RSYNC} -avz toor@freebsd10.rdznl.info:/usr/src/ /usr/src

${RSYNC} -avz --exclude='usr/src/release/*' toor@freebsd10.rdznl.info:/usr/obj/ /usr/obj


