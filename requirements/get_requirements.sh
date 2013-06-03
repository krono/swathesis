#!/bin/sh

PROGRAM=`echo $0 | sed 's%.*/%%'`

ECHO="/bin/echo -e"
if type wget >/dev/null 2>/dev/null; then
  FETCH="wget --quiet"
elif type curl >/dev/null 2>/dev/null; then
  FETCH="curl -s -S -O"
else
  FETCH="$ECHO Please download "
fi


if [ -z "$TDS_DEST" ]; then
  $ECHO "run from install or run as"
  $ECHO "\tTDS_DEST=$(kpsewhich -var-value TEXMFHOME) $0"
  exit 1
fi

if type ctanify >/dev/null 2>/dev/null; then
  CTANIFY=ctanify
elif [ -x $PWD/ctanify ]; then
    CTANIFY=$PWD/ctanify
else
  CTANIFYURL=http://mirror.ctan.org/tex-archive/support/ctanify/ctanify
  $FETCH $CTANIFYURL >/dev/null 2>/dev/null
  if [ $? -ne 0 ]; then
    $ECHO "Cannot download ctanify, abort"
    exit 100
  fi
  CTANIFY=$PWD/ctanify
  chmod +x $CTANIFY
fi

if [ ! -d "$TDS_DEST" ]; then
  mkdir -p "$TDS_DEST"
fi

WORKING=$(mktemp -q -d -t "$PROGRAM-XXXXXX")
if [ $? -ne 0 ]; then
  $ECHO "$0: Can't create temp dir, exiting..."
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
    unzip $F >/dev/null 2>/dev/null
    cd $_P_d
  fi
}

_get_ctan() {
  PKG="$1"; shift
  PRE_CMD="$1"; shift
  POST_CMD="$1"; shift

  _P_ctan=$PWD

  CTAN=$PKG.zip
  CTANIFYOUT=$PKG.tar.gz
  TDS=$PKG.tds.zip
  URL=http://mirrors.ctan.org/macros/latex/contrib/$CTAN
  if [ ! -f $CTAN ]; then
    $FETCH $URL >/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
      $ECHO "Cannot download $CTAN from $URL, abort"
      exit 100
    fi
  fi
  unzip $CTAN >/dev/null 2>/dev/null
  cd $PKG
  if [ ! -z "$PRE_CMD" ]; then $PRE_CMD >/dev/null 2>/dev/null; fi
  $CTANIFY "$@" >/dev/null 2>/dev/null
  if [ ! -f "$CTANIFYOUT" ]; then
    $ECHO "ctanify failed, abort"
    exit 128
  fi
  if [ ! -z "$POST_CMD" ]; then $POST_CMD >/dev/null 2>/dev/null; fi
  gunzip -c $CTANIFYOUT | tar x
  mv $TDS $_P_ctan

  cd $_P_ctan

  rm -r $CTAN $PKG
  $ECHO "$TDS"
}

_get_tds() {
  PKG="$1"; shift
  URL="$1"; shift
  if [ -z "$URL" ]; then
    TDS=$PKG.tds.zip
    URL="http://mirrors.ctan.org/install/macros/latex/contrib/$TDS"
  else
    TDS=`basename "$URL"`
  fi
  if [ ! -f $TDS ]; then
    $FETCH $URL >/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
      $ECHO "Cannot download $TDS from $URL, abort"
      exit 100
    fi
  fi
  $ECHO "$TDS"
}

_has_package() {
  PACKAGETEST=$(mktemp -q -t pkgtst$1-XXXX.tex)
  echo "\\relax%
\\renewcommand{\\GenericWarning}[2]{\\GenericError{#1}{#2}{}{ERROR}}%
\\documentclass{article}%
\\nofiles%
\\RequirePackage{$1}[$2]%
\\begin{document}\\end{document}" > $PACKAGETEST
  (kpsewhich $1.sty && pdflatex \
    -output-directory "$WORKING" \
    -draftmode \
    -halt-on-error $PACKAGETEST ) >/dev/null 2>/dev/null
  EXIT=$?
  rm -f $PACKAGETEST
  (exit $EXIT)
  return $EXIT
}

_has_class() {
  CLASSTEST=$(mktemp -q -t clstst$1-XXXX.tex)
  echo "\\relax%
\\renewcommand{\\GenericWarning}[2]{\\GenericError{#1}{#2}{}{ERROR}}%
\\documentclass{$1}[$2]%
\\nofiles%
\\begin{document}\\end{document}" > $CLASSTEST
  (kpsewhich $1.cls && pdflatex -draftmode \
    -output-directory "$WORKING" \
    -halt-on-error $CLASSTEST ) >/dev/null 2>/dev/null
  EXIT=$?
  rm -f $CLASSTEST
  (exit $EXIT)
  return $EXIT
}


if _has_class "llncs" "2010/07/12"; then
  $ECHO ">> llncs found."
else
 if [ ! -f llncs.tds.zip ]; then
    ./tdsify_llncs.sh
  fi
  _deploy_tds llncs.tds.zip
fi

if _has_package "scrbase" "2011/06/07"; then
  $ECHO ">> current KOMA-script found".
else
  TDS=`_get_tds "koma-script" ""`
  _deploy_tds $TDS
fi

if _has_package "titlepage" "2012/12/18"; then
  $ECHO ">> titlepage found."
else
  TDS=`_get_tds "titlepage" "http://www.komascript.de/files/titlepage.tds__0.zip"`
  _deploy_tds $TDS
fi

if _has_package "fontaxes" "2011/12/16"; then
  $ECHO ">> current fontaxes found."
else
  F=fontaxes
  TDS=`_get_ctan $F "pdflatex $F.ins" "" $F.ins $F.pdf README "test-$F.tex=doc/latex/$F"`
  _deploy_tds $TDS
fi

if _has_package "microtype" "2011/08/18"; then
  $ECHO ">> current microtype found."
else
  TDS=`_get_tds "microtype" ""`
  _deploy_tds $TDS
fi

if _has_package "ctable" "2012/05/28"; then
  $ECHO ">> current ctable found."
else
  C=ctable
  TDS=`_get_ctan $C "" "" $C.ins $C.dtx $C.pdf inst=doc/latex/$C "doc/*=doc/latex/$C/" README`
  _deploy_tds "$TDS"
fi
