#!/bin/sh --
pkg query "%t %n-%v" | sort -n -k1 | while read timestamp pkgname; do echo "$(date -r $timestamp) $pkgname"; done
