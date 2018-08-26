PREFIX=/opt


INCLUDES= jail-functions.sh svn-functions.sh zfs-functions.sh

all:

install:	${INCLUDES}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/share/rdnzl/inc
	${INSTALL} -o root -g wheel -m 444  $> ${DESTDIR}${PREFIX}/share/rdnzl/inc

