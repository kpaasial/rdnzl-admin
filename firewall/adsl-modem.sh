#!/bin/sh --

ANCHOR="adsl-modem"
WAN=vr0
IP_ADSL_MODEM="192.168.1.1"
IP_WAN_ALIAS="192.168.1.200"


/sbin/pfctl -a "${ANCHOR}" -F rules
/sbin/pfctl -a "${ANCHOR}" -F nat
/sbin/pfctl -a "${ANCHOR}" -f - <<EOT
nat on ${WAN} inet from any to ${IP_ADSL_MODEM} -> ${IP_WAN_ALIAS} port 1024:65535
pass out quick on ${WAN} inet from any to ${IP_ADSL_MODEM} label "PASS_${WAN}_ADSLMODEM_OUT"
EOT
