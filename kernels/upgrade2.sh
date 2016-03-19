#!/bin/sh --

echo "$0 starting at $(/bin/date '+%d.%m.%Y %H:%M:%S')"

/usr/sbin/mergemaster -p

/usr/bin/make -C /usr/src installworld

/usr/sbin/mergemaster

/usr/bin/make -C /usr/src -D BATCH_DELETE_OLD_FILES delete-old delete-old-libs

echo "$0 done at $(/bin/date '+%d.%m.%Y %H:%M:%S')"

