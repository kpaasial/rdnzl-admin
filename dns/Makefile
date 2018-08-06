
LOCALBASE=/usr/local

SERVICE=/usr/sbin/service

UNBOUND_INCLUDES = joesgarage.inc


all:

install: install-conf 

install-conf: ${UNBOUND_INCLUDES}
	/bin/mkdir -p ${LOCALBASE}/etc/unbound/include
	${INSTALL} -o root -g wheel -m 644 $> ${LOCALBASE}/etc/unbound/include


reload:
	${SERVICE} 

restart:
