

.SUFFIXES   : .sh .sh.in

.sh.in.sh   :
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}

PREFIX=/opt

SCRIPTS= bootstrap-buildjail.sh build-sources.sh new-sources.sh setup-portsjail.sh update-buildjail.sh update-host.sh 

CONFIGS= sysupdate-setup.rc.sample 

all: ${SCRIPTS}

install: install-scripts install-configs

install-scripts: ${SCRIPTS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin 

install-configs: ${CONFIGS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/etc/rdnzl-admin
	${INSTALL} -o root -g wheel -m 444 $> ${DESTDIR}${PREFIX}/etc/rdnzl-admin


bootstrap-buildjail.sh: bootstrap-buildjail.sh.in

build-sources.sh: build-sources.sh.in

new-sources.sh: new-sources.sh.in

setup-portsjail.sh: setup-portsjail.sh.in

update-buildjail.sh: update-buildjail.sh.in

update-host.sh: update-host.sh.in

clean:
	-rm ${SCRIPTS}
