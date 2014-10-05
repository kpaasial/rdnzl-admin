PREFIX=/opt


INCLUDES= jail-functions.sh

all:

install:	${INCLUDES}
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/share/rdnzl
	${INSTALL} -o root -g wheel -m 444  $> ${DESTDIR}${PREFIX}/share/rdnzl

