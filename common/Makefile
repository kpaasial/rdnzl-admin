




PREFIX=/opt

BIN_SCRIPTS= tmux-session

CONFIG_FILES= rdnzl.conf

all:


install:  install-bin install-conf


install-conf: $(CONFIG_FILES)
	$(INSTALL) -o root -g wheel -m 644  $> $(PREFIX)/etc

install-bin: $(BIN_SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/bin


