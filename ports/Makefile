
PREFIX=/opt

LOCALBASE=/usr/local

SCRIPTS= build-packages.sh ports-dependencies.sh  update-ports.sh

ETCFILES= ports-freebsd.txt

POUDRIEREDOTFILES= make.conf



all:

install-scripts:
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 ${SCRIPTS} ${DESTDIR}${PREFIX}/sbin


install-etc-files:
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/etc
	${INSTALL} -o root -g wheel -m 644 ${ETCFILES} ${DESTDIR}${PREFIX}/etc

install-dot-files:
	${INSTALL} -o root -g wheel -m 644 ${POUDRIEREDOTFILES} ${DESTDIR}${LOCALBASE}/etc/poudriere.d


install:	install-scripts install-etc-files install-dot-files



