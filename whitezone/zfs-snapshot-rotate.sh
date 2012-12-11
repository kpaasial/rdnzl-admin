#!/bin/sh --


/usr/local/bin/zfs_snapshot_expired.py zwhitezone

/usr/local/bin/zfs_snapshot_expired.py zwhitezone | fgrep '@'  | xargs -n1 /sbin/zfs destroy
