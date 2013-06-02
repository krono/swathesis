#!/bin/sh

PROGRAM=`echo $0 | sed 's%.*/%%'`

if type wget >/dev/null 2>/dev/null; then
  FETCH="wget --quiet"
elif type curl >/dev/null 2>/dev/null; then
  FETCH="curl -s -S -O"
else
  FETCH="echo Please download "
fi

if [ -z "$TDS_DEST" ]; then
  echo "run from install or run as"
  echo "\tTDS_DEST=$(kpsewhich -var-value TEXMFHOME) $0"
  exit 1
fi

if [ ! -d "$TDS_DEST" ]; then
  mkdir -p "$TDS_DEST"
fi

WORKING=$(mktemp -q -d "$PROGRAM-XXXXXX")
if [ $? -ne 0 ]; then
  echo "$0: Can't create temp dir, exiting..."
  exit 1
else
  mkdir -p $WORKING
  trap 'rm -rf "$WORKING"' EXIT
fi

_deploy_tds() {
  if type ditto >/dev/null 2>/dev/null; then
    ditto -x -k $1 $TDS_DEST
  else
    _P_d=$PWD;
    case $1 in
      /*) F=$1;;
      *) F=$PWD/$1;;
    esac
    cd $TDS_DEST
    unzip $F
    cd $_P_d
  fi
}

_has_package() {
  (kpsewhich $1.sty && pdflatex \
    -output-directory "$WORKING" \
    -draftmode \
    -halt-on-error \
    "\\relax\
\\renewcommand{\\GenericWarning}[2]{\\GenericError{#1}{#2}{}{ERROR}}\
\\documentclass{article}\
\\nofiles\
\\RequirePackage{$1}[$2]\
\\begin{document}\\end{document}") >/dev/null 2>/dev/null
}

_has_class() {
  (kpsewhich $1.cls && pdflatex -draftmode \
    -output-directory "$WORKING" \
    -halt-on-error \
    "\\relax\
\\renewcommand{\\GenericWarning}[2]{\\GenericError{#1}{#2}{}{ERROR}}\
\\documentclass{$1}[$2]\
\\nofiles
\\begin{document}\\end{document}") >/dev/null 2>/dev/null
}


if _has_class "llncs" "2010/07/12"; then
  echo "$PROGRAM: llncs found."
else
 if [ ! -f llncs.tds.zip ]; then
    ./tdsify_lncs.sh
  fi
  _deploy_tds llncs.tds.zip
fi

if _has_package "titlepage" "2012/12/18"; then
  echo "$PROGRAM: titlepage found."
else
  TDS="titlepage.tds__0.zip"
  URL="http://www.komascript.de/files/$TDS"
  if [ ! -f $TDS ]; then
    $FETCH $URL
  fi
  _deploy_tds $TDS
fi

if _has_package "microtype" "2011/08/18"; then
  echo "$PROGRAM: current microtype found."
else
  TDS=microtype.tds.zip
  URL="http://mirrors.ctan.org/install/macros/latex/contrib/$TDS"
  if [ ! -f $TDS ]; then
    $FETCH $URL
  fi
  _deploy_tds $TDS
fi
