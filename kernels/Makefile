



SYSCONFDIR=/usr/src/sys/i386/conf

ETCDIR=/etc

KERNCONFFILES=RDNZL

ETCFILES=src.conf

all:

install: install-sysconf install-etc

install-sysconf:	${KERNCONFFILES}
	${INSTALL} -o root -g wheel -m 640 $> ${SYSCONFDIR}


install-etc:	${ETCFILES}
	${INSTALL} -o root -g wheel -m 640 $> ${ETCDIR} 


