#!/bin/sh

PROGRAM=`echo $0 | sed 's%.*/%%'`

if [ ! -z "$ZSH_VERSION" ]; then
  setopt shwordsplit
fi
ECHO="/usr/bin/printf %b\\n"

if type wget >/dev/null 2>/dev/null; then
  FETCH="wget --quiet"
elif type curl >/dev/null 2>/dev/null; then
  FETCH="curl -s -S -O"
else
  FETCH="$ECHO Please download "
fi

if type ditto >/dev/null 2>/dev/null; then
  _pkg_x() {
    ditto -x -k $1 $2
  }
  _pkg_c() {
    ditto -c -k $1 $2
  }
  _cp() {
    ditto "$@"
  }
else
  _pkg_x() {
    _P_PKG_X=$PWD; cd $2
    unzip $1 >/dev/null 2>/dev/null
    E=$?; cd $_P_PKG_X
    return $E
  }
  _pkg_c() {
    _P_PKG_C=$PWD; F=$2.$$; cd $1
    zip -q -r -X $F * >/dev/null 2>/dev/null
    E=$?; cd $_P_PKG_C; mv $F $2
    return $E
  }
  _cp() {
    cp -r "$@"
  }
fi


SRC="llncs2e.zip"
URL="ftp://ftp.springer.de/pub/tex/latex/llncs/latex2e/$SRC"

WORKING=$(mktemp -q -d -t "$PROGRAM-XXXXXX")
if [ $? -ne 0 ]; then
  $ECHO "$0: Can't create temp dir, exiting..."
  exit 1
else
  mkdir -p $WORKING
  trap 'rm -rf "$WORKING"' EXIT
fi

_P=$PWD
cd $WORKING

if [ -f $_P/$SRC ]; then
  _pkg_x $_P/$SRC .
else
  $FETCH $URL
  _pkg_x $SRC .
fi

TEX=tds/tex/latex/llncs
DOC=tds/doc/latex/llncs
BST=tds/bibtex/bst/llncs

if [ ! -d "$TEX" ]; then mkdir -p "$TEX"; fi
_cp llncs.cls sprmindx.sty "$TEX"

if [ ! -d "$BST" ]; then mkdir -p "$BST"; fi
_cp *.bst "$BST"

if [ ! -d "$DOC" ]; then mkdir -p "$DOC"; fi
_cp *.txt *.d* *.ind llncsdoc.* "$DOC"

_pkg_c tds $_P/llncs.tds.zip
rm -rf tds $SRC

cd $_P
