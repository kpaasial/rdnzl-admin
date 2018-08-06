
LOCALBASE=/usr/local

SERVICE=/usr/sbin/service


UNBOUND_CONFIG= unbound.conf

UNBOUND_INCLUDES= joesgarage.inc


all:

install: install-conf install-includes 

install-includes: ${UNBOUND_INCLUDES}
	/bin/mkdir -p ${LOCALBASE}/etc/unbound/include
	${INSTALL} -o root -g wheel -m 644 $> ${LOCALBASE}/etc/unbound/include

install-conf: ${UNBOUND_CONFIG}
	${INSTALL} -o root -g wheel -m 644 $> ${LOCALBASE}/etc/unbound

reload:
	${SERVICE} unbound reload 

restart:
