
PREFIX=/opt

PFCTL=/sbin/pfctl

PF_CONF= pf.conf

SCRIPTS= firewall-log.sh

SERVICE= /usr/sbin/service

all:

install: install-scripts install-pf-conf

install-scripts:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 


install-pf-conf: ${PF_CONF}
	$(INSTALL) -o root -g wheel -m 600 $> /etc/pf.conf

check:
	${PFCTL} -n -f ${PF_CONF}

reload:
	${SERVICE} pf reload

restart:
	${SERVICE} pf restart
