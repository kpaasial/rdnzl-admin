# Some common settings that don't depend on anything else

# The name of the ZFS pool.
ZFS_POOL="zrdnzltank"

# Jails are located under this ZFS filesystem
JAIL_BASEFS="${ZFS_POOL}/DATA/jails"

# System sources are kept under this ZFS filesystem
SRC_BASEFS="${ZFS_POOL}/DATA/src"


# Basis for the ZFS user properties used.
USERPROPBASE="info.rdnzl"

KERNELREVPROP="${USERPROPBASE}:kernelsvnrevision"
KERNELBRANCHPROP="${USERPROPBASE}:kernelbranch"
WORLDREVPROP="${USERPROPBASE}:worldsvnrevision"
WORLDBRANCHPROP="${USERPROPBASE}:worldbranch"

