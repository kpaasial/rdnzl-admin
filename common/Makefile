




PREFIX=/usr/local

BIN_SCRIPTS= tmux-session cputemp.sh


all:


install:  install-bin


install-bin: $(BIN_SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/bin

