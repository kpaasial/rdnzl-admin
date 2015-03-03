
#.SUFFIXES   : .sh .sh.in

#.sh.in.sh   :
#	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}



PREFIX=/opt

SCRIPTS= build-packages.sh ports-playground.sh  update-ports.sh

ETCFILES= ports-firewall.txt

all:


install:
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 ${SCRIPTS} ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/etc
	${INSTALL} -o root -g wheel -m 644 ${ETCFILES} ${DESTDIR}${PREFIX}/etc



