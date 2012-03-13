#! /bin/sh
#
# Download gravity models for use by GeographicLib::GravityModel.
#
# Copyright (c) Charles Karney (2011) <charles@karney.com> and licensed
# under the MIT/X11 License.  For more information, see
# http://geographiclib.sourceforge.net/
#
# $Id: c51df2bd26c5734d35de1fc47d60c433680c6721 $

DEFAULTDIR="@DEFAULTDIR@"
usage() {
    cat <<EOF
usage: $0 [-p parentdir] [-d] [-h] gravitymodel...

This program downloads and installs the gravity models used by the
GeographicLib::GravityModel class and the Gravity tool to compute
gravity fields.  gravitymodel is one of more of the names from this
table:

                       size (kB)
  name     degree    tar.bz2  disk
  egm84      18       27      26   
  egm96      360     2100    2100 
  egm2008   2190    76000   75000
  wgs84      20        1       1    

The size columns give the download and installed sizes of the models.
In addition you can specify

  all = all of the supported gravity models
  minimal = egm96 wgs84

If no name is specified then minimal is assumed.

-p parentdir (default $DEFAULTDIR) specifies where the
datasets should be stored.  The "Default gravity path" listed when running

  Gravity -h

should be parentdir/gravity.  This script must be run by a user with
write access to this directory.

If -d is provided, the temporary directory which holds the downloads,
${TMPDIR:-/tmp}/gravity-XXXXXXXX, will be saved.  -h prints this help.

For more information on the gravity models, visit

  http://geographiclib.sourceforge.net/html/gravity.html

EOF
}

PARENTDIR="$DEFAULTDIR"
DEBUG=
while getopts hp:d c; do
    case $c in
        h )
            usage;
            exit 0
            ;;
        p ) PARENTDIR="$OPTARG"
            ;;
        d ) DEBUG=y
            ;;
        * )
            usage 1>&2;
            exit 1
            ;;
    esac
done
shift `expr $OPTIND - 1`

test -d "$PARENTDIR"/gravity || mkdir -p "$PARENTDIR"/gravity 2> /dev/null
if test ! -d "$PARENTDIR"/gravity; then
    echo Cannot create directory $PARENTDIR/gravity 1>&2
    exit 1
fi

TEMP=
if test -z "$DEBUG"; then
trap 'trap "" 0; test "$TEMP" && rm -rf "$TEMP"; exit 1' 1 2 3 9 15
trap            'test "$TEMP" && rm -rf "$TEMP"'            0
fi
TEMP=`mktemp --tmpdir --quiet --directory gravity-XXXXXXXX`

if test -z "$TEMP" -o ! -d "$TEMP"; then
    echo Cannot create temporary directory 1>&2
    exit 1
fi

WRITETEST="$PARENTDIR"/gravity/write-test-`basename $TEMP`
if touch "$WRITETEST" 2> /dev/null; then
    rm -f "$WRITETEST"
else
    echo Cannot write in directory $PARENTDIR/gravity 1>&2
    exit 1
fi

set -e

cat > $TEMP/all <<EOF
egm84
egm96
egm2008
wgs84
EOF

test $# -eq 0 && set -- minimal

while test $# -gt 0; do
    if grep "^$1\$" $TEMP/all > /dev/null; then
	echo $1
    else
	case "$1" in
	    all )
		cat $TEMP/all
		;;
	    minimal )		# same as no argument
		echo egm96; echo wgs84
		;;
	    * )
		echo Unknown gravity model $1 1>&2
		exit 1
		;;
	esac
    fi
    shift
done > $TEMP/list

sort -u $TEMP/list > $TEMP/todo

while read file; do
    echo download $file.tar.bz2 ...
    URL="http://downloads.sourceforge.net/project/geographiclib/gravity-distrib/$file.tar.bz2?use_mirror=autoselect"
    ARCHIVE=$TEMP/$file.tar.bz2
    wget -O$ARCHIVE $URL
    echo unpack $file.tar.bz2 ...
    tar vxojf $ARCHIVE -C $PARENTDIR
    echo gravity $file installed.
done < $TEMP/todo

if test "$DEBUG"; then
    echo Saving temporary directory $TEMP
fi
cat <<EOF

Gravity models `tr '\n' ' ' < $TEMP/todo`
downloaded and installed in $PARENTDIR/gravity.

EOF