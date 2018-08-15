




PREFIX=/opt

LOCALBASE=/usr/local

BUILT_SCRIPTS= package-updater.sh

SCRIPTS=    check-packages.sh check-port-updates.sh fetch-updating.sh fetch-audit.sh \
            ${BUILT_SCRIPTS}

PKGREPOFILES = FreeBSD.conf local.conf


package-updater.sh: package-updater.sh.in
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}


install: install-scripts install-repo-files

install-scripts:	${SCRIPTS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin 

install-repo-files: ${PKGREPOFILES}
	/bin/mkdir -p ${DESTDIR}${LOCALBASE}/etc/pkg/repos
	${INSTALL} -o root -g wheel -m 644 ${PKGREPOFILES} ${DESTDIR}${LOCALBASE}/etc/pkg/repos


clean:
	rm ${BUILT_SCRIPTS}

