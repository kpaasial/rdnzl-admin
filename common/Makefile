




PREFIX=/usr/local

SBIN_SCRIPTS= build-release.sh update-src.sh cputemp.sh
BIN_SCRIPTS= tmux-session


all:


install:    install-sbin install-bin

install-sbin: $(SBIN_SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 

install-bin: $(BIN_SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/bin

