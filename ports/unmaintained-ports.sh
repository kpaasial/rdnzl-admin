#!/bin/sh --


/usr/bin/nawk -F"|" '$6 == "ports@FreeBSD.org" {print $2}' /usr/ports/INDEX-`uname -r | cut -d'.' -f1`

