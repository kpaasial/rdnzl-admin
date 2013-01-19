




PREFIX=/usr/local

SCRIPTS= update-ports.sh build-packages.sh zfs-backup.sh \
    zfs-snapshot-rotate.sh


all:


install:	$(SCRIPTS)
	$(INSTALL) -o root -g wheel -m 755 $> $(PREFIX)/sbin 


