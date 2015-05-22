




PREFIX=/opt

BIN_SCRIPTS= tmux-session cputemp.sh

CONFIGS= rdnzl.conf

all:


install:  install-bin install-configs


install-bin: $(BIN_SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/bin


install-configs: $(CONFIGS)
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/etc
	${INSTALL} -d -o root -g wheel ${DESTDIR}${PREFIX}/etc/rdnzl-admin
	$(INSTALL) -o root -g wheel -m 644 $> $(PREFIX)/etc/rdnzl-admin
