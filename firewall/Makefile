



PREFIX=/usr/local

SCRIPTS= firewall-log.sh update-pf-tables.sh update-src-obj.sh
ETCFILES= pf-tables.txt

all:


install: install-scripts install-etc

install-scripts:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 

install-etc:	${ETCFILES}
	${INSTALL} -o root -g wheel -m 640 $> ${PREFIX}/etc

