#!/bin/sh
# -----------------------------------------------------------------------------
# This software is in the public domain, furnished "as is", without technical
# support, and with no warranty, express or implied, as to its usefulness for
# any purpose.
#
# tarCopy.sh
#
# Usage: tarCopy.sh todir files_to_copy
#
# Uses tar to copy files in the current working directory to files in the
# todir directory. The copies will have the same path relative to todir that
# they had with the current directory.
#
# Currently only called from storeToCache.sh, so there is minimal usage error
# checking. If there are no files to copy it simply exits as though it
# were successfull.

if [ $# -lt 2 ]
then
	exit 0
fi

todir=${1}
shift
tar chf - $* | (cd ${todir}; tar xf -)

