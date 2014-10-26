
#.SUFFIXES   : .sh .sh.in

#.sh.in.sh   :
#	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}



PREFIX=/opt

SCRIPTS= build-packages.sh ports-playground.sh  update-ports.sh


all: ${SCRIPTS}


install:	${SCRIPTS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin 

#build-packages.sh: build-packages.sh.in

#ports-playground.sh: ports-playground.sh.in

#update-ports.sh: update-ports.sh.in


#clean:
#	-rm ${SCRIPTS}
