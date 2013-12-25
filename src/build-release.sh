#!/bin/sh --

cd /usr/src || (echo "No /usr/src directory." && exit 1)

test -f Makefile || (echo "System sources missing from /usr/src?" && exit 1)

: ${SVN_CMD:=$(which svn 2>/dev/null || which svnlite 2>/dev/null)}

LAST_CHANGED_REV=$( ${SVN_CMD} info . | grep '^Last Changed Rev' | cut -f 2 -d':' ) 

SVNVERSION=r${LAST_CHANGED_REV# }

RELATIVEURL=$( ${SVN_CMD} info . | grep '^Relative URL' | cut -f 2 -d':')

BRANCH="${RELATIVEURL# ^/}"

echo "SVNVERSION: $SVNVERSION"
echo "BRANCH: $BRANCH"

cd /usr/src/release || exit 1

make clean || exit 1

make -D NOPORTS -D NODVD release || exit 1

make -D NOPORTS -D NODVD install DESTDIR=/var/freebsd-snapshot/${BRANCH}/${SVNVERSION} || exit 1

ln -fhs /var/freebsd-snapshot/${BRANCH}/${SVNVERSION} /var/freebsd-snapshot/${BRANCH}/latest


