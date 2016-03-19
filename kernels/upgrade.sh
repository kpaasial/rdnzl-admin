#!/bin/sh --

/sbin/adjkerntz -i

/sbin/mount -a -t ufs || exit 1

/usr/sbin/service syscons start

#/usr/sbin/service netif start rl0

#/usr/sbin/service nfsclient start || exit 1

/bin/sleep 10

#/sbin/mount /usr/src || exit 1

#/sbin/mount /usr/obj || exit 1

/usr/bin/script "/var/log/rdnzl/upgrade.log.$(/bin/date '+%Y-%m-%d_%H:%M:%S').txt" /bin/sh /upgrade2.sh

