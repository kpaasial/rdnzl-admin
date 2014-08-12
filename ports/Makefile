




PREFIX=/opt

SCRIPTS= build-packages.sh nostage.sh unmaintained-ports.sh update-ports.sh


all:


install:	${SCRIPTS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin 


