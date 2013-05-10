#!/bin/sh


: ${PORTSTXT:="/usr/local/etc/ports.txt"}
: ${BUILD_JAIL:="release91i386"}


while getopts f:j: o
do
    case "$o" in
    f)  PORTSTXT="$OPTARG";;
    j)  BUILD_JAIL="$OPTARG";;
    esac

done

shift $((OPTIND-1))



echo "Using ${PORTSTXT} as the list for ports to build."
echo "Using ${BUILD_JAIL} as the build jail."


/usr/local/bin/poudriere bulk -f ${PORTSTXT} -j ${BUILD_JAIL} 


