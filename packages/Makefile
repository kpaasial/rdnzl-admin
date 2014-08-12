




PREFIX=/opt

BUILT_SCRIPTS= package-updater.sh

SCRIPTS=    check-packages.sh check-port-updates.sh fetch-updating.sh fetch-audit.sh \
            ${BUILT_SCRIPTS}



package-updater.sh: package-updater.sh.in
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}



install:	${SCRIPTS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin 


clean:
	rm ${BUILT_SCRIPTS}

