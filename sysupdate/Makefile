




PREFIX=/opt

SCRIPTS= setup-buildjail.sh setup-clonejail.sh update-buildjail.sh update-host.sh 

CONFIGS= sysupdate-setup.rc.sample 

all:

install: install-scripts install-configs

install-scripts: ${SCRIPTS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin 

install-configs: ${CONFIGS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/etc/rdnzl-admin
	${INSTALL} -o root -g wheel -m 444 $> ${DESTDIR}${PREFIX}/etc/rdnzl-admin
