



PREFIX=/opt

PFCTL=/sbin/pfctl

SERVICE=/usr/sbin/service

PF_CONF= pf.conf

SCRIPTS= firewall-log.sh update-pf-tables.sh
ETCFILES= pf-tables.txt ${PF_CONF}

all:


install: install-scripts install-etc

install-scripts:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 

install-etc:	${ETCFILES}
	${INSTALL} -o root -g wheel -m 640 $> ${PREFIX}/etc

check:
	${PFCTL} -n -f ${PF_CONF}

reload:
	${SERVICE} pf reload

restart:
	${SERVICE} pf restart
