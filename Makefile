




PREFIX=/root

SCRIPTS= update-ports.sh build-packages.sh


all:


install:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/bin 


