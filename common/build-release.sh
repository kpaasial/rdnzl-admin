#!/bin/sh --

cd /usr/src || exit 1

test -f Makefile || exit 1

SVNVERSION=$(svnliteversion)

echo "SVNVERSION: $SVNVERSION"

cd /usr/src/release || exit 1

make clean || exit 1

make -D NOPORTS -D NODVD release || exit 1

make -D NOPORTS -D NODVD install DESTDIR=/var/freebsd-snapshot/stable/10/$SVNVERSION || exit 1

ln -fhs /var/freebsd-snapshot/stable/10/$SVNVERSION /var/freebsd-snapshot/stable/10/latest


