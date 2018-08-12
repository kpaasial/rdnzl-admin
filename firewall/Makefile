
PREFIX=/opt

PFCTL=/sbin/pfctl

PF_CONF= pf.conf.freebsd

SCRIPTS= firewall-log.sh

all:

install: install-scripts install-pf-conf

install-scripts:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 


install-pf-conf: ${PF_CONF}
	$(INSTALL) -o root -g wheel -m 600 $> /etc/pf.conf

check:
	${PFCTL} -n -f ${PF_CONF}

reload:
	${PFCTL} -f /etc/pf.conf

restart:
	${PFCTL} -d
	${PFCTL} -e
	${PFCTL} -f /etc/pf.conf
