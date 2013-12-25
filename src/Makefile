




PREFIX=/usr/local

SBIN_SCRIPTS= build-release.sh


all:


install:    install-sbin

install-sbin: $(SBIN_SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 
