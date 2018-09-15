

PREFIX=/opt

SCRIPTS= media-backup.sh zfs-backup.sh

all: ${SCRIPTS}


install:	${SCRIPTS}
	${INSTALL} -o root -g wheel -m 755 $> ${DESTDIR}${PREFIX}/sbin

