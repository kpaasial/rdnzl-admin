




PREFIX=/usr/local

SCRIPTS=    check-packages.sh check-port-updates.sh fetch-updating.sh fetch-audit.sh \
            package-updater.sh


all:


install:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 


