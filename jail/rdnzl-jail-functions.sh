# Functions for dealing with jail(8)s.

rdnzl_in_jail()
{
    jailname="$1"
    shift
    jexec -U root "${jailname}" "$@"
}

