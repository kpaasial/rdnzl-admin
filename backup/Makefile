

.SUFFIXES: .sh .sh.in

PREFIX=/opt

BUILT_SCRIPTS= media-backup.sh zfs-backup.sh

SCRIPTS= ${BUILT_SCRIPTS}


all: ${SCRIPTS}



.sh.in.sh:
	sed -e "s|@@PREFIX@@|${PREFIX}|g" <${.IMPSRC} >${.TARGET}

media-backup.sh: media-backup.sh.in

zfs-backup.sh: zfs-backup.sh.in

install:	${SCRIPTS}
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin

clean:
	- rm ${BUILT_SCRIPTS}

