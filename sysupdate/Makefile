

.SUFFIXES   : .sh .sh.in .sample .sample.in

.sh.in.sh   :
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}

.sample.in.sample   :
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.ALLSRC} >${.TARGET}

PREFIX=/opt

SCRIPTS= bootstrap-buildjail.sh build-sources.sh new-sources.sh setup-portsjail.sh update-buildjail.sh update-host.sh 

INCLUDES= sysupdate-common.sh

CONFIGS= sysupdate.rc.sample 

all: ${SCRIPTS} ${CONFIGS} ${INCLUDES}

install: install-scripts install-configs install-includes

install-scripts: ${SCRIPTS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin 

install-configs: ${CONFIGS}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/etc/rdnzl
	${INSTALL} -o root -g wheel -m 444 $> ${DESTDIR}${PREFIX}/etc/rdnzl

install-includes: ${INCLUDES}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/share/rdnzl
	${INSTALL} -o root -g wheel -m 444 $> ${DESTDIR}${PREFIX}/share/rdnzl

bootstrap-buildjail.sh: bootstrap-buildjail.sh.in

build-sources.sh: build-sources.sh.in

new-sources.sh: new-sources.sh.in

setup-portsjail.sh: setup-portsjail.sh.in

update-buildjail.sh: update-buildjail.sh.in

update-host.sh: update-host.sh.in

sysupdate-common.sh: sysupdate-common.sh.in

sysupdate.rc.sample: sysupdate.rc.sample.in

clean:
	-rm ${SCRIPTS} ${INCLUDES} ${CONFIGS}
