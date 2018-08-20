




PREFIX=/opt

LOCALBASE=/usr/local

SCRIPTS= check-port-updates.sh package-check.sh package-updater.sh

PKGREPOFILES = FreeBSD.conf local.conf


all:

install: install-scripts install-repo-files

install-scripts:	${SCRIPTS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin 

install-repo-files: ${PKGREPOFILES}
	/bin/mkdir -p ${DESTDIR}${LOCALBASE}/etc/pkg/repos
	${INSTALL} -o root -g wheel -m 644 ${PKGREPOFILES} ${DESTDIR}${LOCALBASE}/etc/pkg/repos


clean:
	rm ${BUILT_SCRIPTS}

