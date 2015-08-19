
PREFIX=/opt


SCRIPTS= pf-tables.sh load-pf-tables.sh update-pf-tables.sh
ETCFILES= pf-tables.conf

all:

install: install-scripts install-etc

install-scripts:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 

install-etc:	${ETCFILES}
	${INSTALL} -o root -g wheel -m 640 $> ${PREFIX}/etc
