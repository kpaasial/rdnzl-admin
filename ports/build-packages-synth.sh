#!/bin/sh

usage()
{
    echo "$0 [-f portsfile] [-P profile] [-p portsdir]"
    exit 0
}


SYNTH_PATH=/usr/local/bin/synth
ENV_PATH=/usr/bin/env
FLOCK_PATH=/usr/local/bin/flock


if [ -z "${RDNZL_CONFIG}" ]; then
    echo "RDNZL_CONFIG not set in environment, can not find configuration."
    exit 1
fi

if [ -f ${RDNZL_CONFIG} ]; then
    . ${RDNZL_CONFIG}
else
    echo "Configuration file ${RDNZL_CONFIG} missing."
    exit 1
fi


while getopts "f:hP:p:" o
do
    case "$o" in
    f)  PORTS_TXT="$OPTARG";;
    h)  usage;;
    P)  SYNTH_PROFILE="$OPTARG";;
    p)	SYNTH_PORTSDIR="$OPTARG";;
    *)  usage;;
    esac

done

shift $((OPTIND-1))


exec 9>/var/db/rdnzl-admin/ports.lock

if ! ${FLOCK_PATH} -n 9  ; then
    echo "Ports tree locked, aborting.";
    exit 1
fi


echo "Using ${PORTS_TXT} as the list for ports to build."

if [ -n "${SYNTH_PROFILE}" ]; then
	SYNTH_ENV="${SYNTH_ENV} SYNTHPROFILE=${SYNTH_PROFILE}"
	echo "Using ${SYNTH_PROFILE} as the Synth profile."
fi

if [ -n "${SYNTH_PORTSDIR}" ]; then
	SYNTH_ENV="${SYNTH_ENV} PORTSDIR=${SYNTH_PORTSDIR}"
	echo "Using ${SYNTH_PORTSDIR} as the ports tree."
fi

${ENV_PATH} ${SYNTH_ENV} ${SYNTH_PATH} just-build ${PORTS_TXT} 


