PREFIX=/opt


INCLUDES= jail-functions.sh svn-functions.sh zfs-functions.sh

all:

install:	${INCLUDES}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/sbin
	${INSTALL} -o root -g wheel -m 444  $> ${DESTDIR}${PREFIX}/sbin

