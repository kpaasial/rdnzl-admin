




PREFIX=/usr/local

SCRIPTS= build-packages.sh portupdater.sh check-packages.sh check-port-updates.sh update-ports.sh clean-pkgdb-dir.sh


all:


install:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 


