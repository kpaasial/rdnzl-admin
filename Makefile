




PREFIX=/usr/local

SCRIPTS_SBIN= update-ports.sh build-packages.sh


all:


install:	$(SCRIPTS_SBIN)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 


