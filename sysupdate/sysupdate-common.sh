
# Basis for the ZFS user properties used.
USERPROPBASE="info.rdnzl"

# Used only on a real host with ZFS root filesystem
KERNELSVNREVISIONPROP="${USERPROPBASE}:kernelsvnrevision"
KERNELSVNBRANCHPROP="${USERPROPBASE}:kernelsvnbranch"

# Used all around to mark the SVN revision of sources and installed world.
SVNREVISIONPROP="${USERPROPBASE}:svnrevision"
SVNBRANCHPROP="${USERPROPBASE}:svnbranch"

