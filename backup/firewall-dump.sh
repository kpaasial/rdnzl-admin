#!/bin/sh --

# TODO: Fetch a copy of disklabel(8) and store it with the backup.

SUDO="doas"
DUMP_CMD="/sbin/dump -0au -f -"


HOST_TO_BACKUP=$(/bin/hostname)

BACKUPPATH="/mnt"

TIMESTAMP=$(/bin/date "+%Y-%m-%d_%R:00")

BACKUPDIR="${BACKUPPATH}/${HOST_TO_BACKUP}/${TIMESTAMP}"

do_dump() {

    FS=$1
    FILEPATH=$2


    echo "FS: $FS"
    echo "FILEPATH: $FILEPATH"

    ${DUMP_CMD} ${FS} | /usr/bin/gzip -2 > ${FILEPATH} 
}

/bin/mkdir -p "${BACKUPDIR}"

# TODO: fetch this list from the host itself, /etc/fstab for example.
for fs in $(/bin/cat /etc/fstab | /usr/bin/cut -d ' ' -f 2); do

    case $fs in
        /)    fileext="_root";;
        none)   continue;;
        /tmp)   continue;;
        /mnt)   continue;;
        /usr/src)   continue;;
        /usr/obj)   continue;;
        *)      fileext=$(echo "$fs" | sed s,/,_,g );;
    esac

    do_dump  "$fs" "${BACKUPDIR}/dump${fileext}.${TIMESTAMP}.gz"

done


exit 0
