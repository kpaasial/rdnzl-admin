




PREFIX=/opt

SCRIPTS= setup-buildjail.sh setup-portsjail.sh update-buildjail.sh update-host.sh 

CONFIGS= sysupdate-setup.rc.sample 

all: ${SCRIPTS}

install: install-scripts install-configs

install-scripts: ${SCRIPTS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin 

install-configs: ${CONFIGS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/etc/rdnzl-admin
	${INSTALL} -o root -g wheel -m 444 $> ${DESTDIR}${PREFIX}/etc/rdnzl-admin



setup-buildjail.sh: setup-buildjail.sh.in
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}

setup-portsjail.sh: setup-portsjail.sh.in
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}

update-buildjail.sh: update-buildjail.sh.in
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}

update-host.sh: update-host.sh.in
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}
