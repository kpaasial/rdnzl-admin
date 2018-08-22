# Functions for dealing with jail(8)s.

rdnzl_in_jail()
{
    jailname="$1"
    shift
    /usr/sbin/jexec -U root "${jailname}" "$@"
}

