#!/bin/sh --

TIMESTAMP=$( /bin/date "+%Y-%m-%d_%R:00" )

/sbin/dump -C16 -b64 -0uanL -h0 -f - /    | /usr/bin/gzip -2 | /usr/bin/ssh -c blowfish kimmo@whitezone dd of=/backup/firewall/root.dump.${TIMESTAMP}.gz
