

ARCH != uname -m

SYSCONFDIR=/usr/src/sys/${ARCH}/conf

ETCDIR=/etc

KERNCONFFILES=FIREWALL

ETCFILES=src.conf

all:

install: install-sysconf

install-sysconf:	${KERNCONFFILES}
	${INSTALL} -o root -g wheel -m 644 $> ${SYSCONFDIR}


install-etc:	${ETCFILES}
	${INSTALL} -o root -g wheel -m 644 $> ${ETCDIR} 


