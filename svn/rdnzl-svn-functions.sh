# Functions for dealing with svn(lite)(1)

SVN_CMD=$(which svn 2>/dev/null || which svnlite 2>/dev/null)
AWK_CMD="/usr/bin/awk"

rdnzl_svn_get_revision()
{
    SVN_WORKCOPY_PATH="$1"

    "${SVN_CMD}" info "${SVN_WORKCOPY_PATH}" | \
        "${AWK_CMD}" '/^Revision:/ {print $2}'
}

rdnzl_svn_get_branch() 
{
    SVN_WORKCOPY_PATH="$1"

    "${SVN_CMD}" info "${SVN_WORKCOPY_PATH}" | \
        "${AWK_CMD}" '/^Relative URL:/ {sub(/\^\//,"", $3); print $3}'
}


