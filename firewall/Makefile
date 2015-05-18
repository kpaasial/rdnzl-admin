



PREFIX=/opt

PFCTL=/sbin/pfctl

SERVICE=/usr/sbin/service

PF_CONF= pf.conf

SCRIPTS= firewall-log.sh pf-tables.sh load-pf-tables.sh update-pf-tables.sh adsl-modem.sh
ETCFILES= pf-tables.txt ${PF_CONF}
RCFILES= pftables
BASEETCFILES= dhclient-exit-hooks


all:


install: install-scripts install-etc install-rc install-base-etc

install-scripts:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 

install-etc:	${ETCFILES}
	${INSTALL} -o root -g wheel -m 640 $> ${PREFIX}/etc

install-rc: ${RCFILES}
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/etc/rc.d

install-base-etc: ${BASEETCFILES}
	$(INSTALL) -o root -g wheel -m 755 $> /etc

check:
	${PFCTL} -n -f ${PF_CONF}

reload:
	${SERVICE} pf reload

restart:
	${SERVICE} pf restart
