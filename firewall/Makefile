



PREFIX=/usr/local

SCRIPTS= firewall-log.sh update-pf-tables.sh
ETCFILES= pf-tables.txt
BASEETCFILES= pf.conf

all:


install: install-scripts install-etc install-base-etc

install-scripts:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 

install-etc:	${ETCFILES}
	${INSTALL} -o root -g wheel -m 640 $> ${PREFIX}/etc

install-base-etc:	${BASEETCFILES}
	${INSTALL} -o root -g wheel -m 640 $> /etc

