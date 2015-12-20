
#.SUFFIXES   : .sh .sh.in

#.sh.in.sh   :
#	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}



PREFIX=/opt

LOCALBASE=/usr/local

SCRIPTS= build-packages.sh ports-dependencies.sh  update-ports.sh

ETCFILES= ports-freebsd10.txt

POUDRIEREDOTFILES= make.conf

all:


install:
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 ${SCRIPTS} ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/etc
	${INSTALL} -o root -g wheel -m 644 ${ETCFILES} ${DESTDIR}${PREFIX}/etc
	${INSTALL} -o root -g wheel -m 644 ${POUDRIEREDOTFILES} ${LOCALBASE}/etc/poudriere.d


