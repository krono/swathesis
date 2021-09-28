#!/bin/sh
set -e
PROGRAM=`echo $0 | sed 's%.*/%%'`

# PREAMBLE
#####################################################################
# SHELL SPECIFICS
if [ ! -z "$ZSH_VERSION" ]; then
  setopt shwordsplit
fi

# COMMAND DETECTION
ECHO="/usr/bin/printf %b\\n"
if type curl >/dev/null 2>/dev/null; then
  FETCH="curl -L -s -S -O"
elif type wget >/dev/null 2>/dev/null; then
  FETCH="wget --quiet"
else
  FETCH="$ECHO Please download "
fi

# SEE IF WE SHOULD RUN
if [ -z "$TDS_DEST" ]; then
  $ECHO "run from install or run as"
  $ECHO "\tTDS_DEST=$(kpsewhich -var-value TEXMFHOME) $0"
  exit 1
fi

if type unzip >/dev/null 2>/dev/null; then
    :
else
    $ECHO "\`unzip' not found, please install."
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

# DETECT DESTINATION
if [ ! -d "$TDS_DEST" ]; then
  mkdir -p "$TDS_DEST"
fi
# TEMP DIRECTORY
WORKING=$(mktemp -q -d -t "$PROGRAM-XXXXXX")
if [ $? -ne 0 ]; then
  $ECHO "Cannot create temp dir, abort"
  exit 1
else
  mkdir -p $WORKING
  trap 'rm -rf "$WORKING"' EXIT
fi

# HELPERS
########################################################################
_deploy_tds() {
  _deploy $TDS_DEST "$@"
}

_deploy() {
  case $- in
    *e*) RESET_E=0 ;;
    *) RESET_E=1 ;;
  esac
  set -e
  if type ditto >/dev/null 2>/dev/null; then
    ditto -x -k $2 $1
  else
    _P_d=$PWD;
    case $2 in
      /*) F=$2;;
      *) F=$PWD/$2;;
    esac
    cd $1
    unzip -n $F >/dev/null 2>/dev/null
    cd $_P_d
  fi
  if [ $RESET_E -ne 0 ]; then
    set +e
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
  URL=https://mirrors.ctan.org/macros/latex/contrib/$CTAN
  if [ ! -f $CTAN ]; then
    $FETCH $URL >/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
      $ECHO "Cannot download $CTAN from $URL, abort"
      exit 100
    fi
  fi
  unzip -n $CTAN >/dev/null 2>/dev/null
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
  _get_tds_ 'macros/latex/contrib' "$@"
}

_get_tds_font() {
  _get_tds_ 'fonts' "$@"
}


_get_tds_() {
  PART="$1"; shift
  PKG="$1"; shift
  URL="$1"; shift
  if [ -z "$URL" ]; then
    TDS=$PKG.tds.zip
    URL="http://mirrors.ctan.org/install/$PART/$TDS"
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

_get_titlepage_github() {
  PKG=uni-titlepage
  HEAD=main
  URL="https://github.com/komascript/$PKG/archive/refs/heads/$HEAD.zip"
  TDS=$PKG.tds.zip
  if [ ! -f $TDS ]; then
    TPWORKING=$(mktemp -q -d -t "$PROGRAM-XXXXXX")
    if [ $? -ne 0 ]; then
      $ECHO "Cannot create temp dir, abort"
      exit 1
    else
      mkdir -p $TPWORKING
      trap 'rm -rf "$TPWORKING"' EXIT
    fi
    _P_tp=$PWD
    cd $TPWORKING
    $FETCH $URL >/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
      $ECHO "Cannot download $PKG from $URL, abort"
      exit 100
    fi
    _deploy $TPWORKING $HEAD.zip
    cd $TPWORKING/$PKG-$HEAD
    perl -pi -e 's/packtdszip =.+$/packtdszip = true/' build.lua
    l3build ctan >/dev/null 2>/dev/null
    _deploy $PWD $PKG-ctan.zip
    mv $TDS $_P_tp
    cd $_P_tp
    #rm -rf $TPWORKING
   fi
  $ECHO "$TDS"
}

_has_package(){
  PACKAGETEST=$(mktemp -q -t pkgtst$1-XXXX.tex)
  echo "\\\\relax%
\\\\documentclass{article}%
\\\\nofiles%
\\\\def\\\\GenericWarning#1#2{\\\\GenericError{#1}{#2}{ERROR}{ERROR}}
\\\\RequirePackage{$1}[$2]%
\\\\begin{document}\\\\end{document}" > $PACKAGETEST
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
  echo "\\\\relax%
\\\\def\\\\GenericWarning#1#2{\\\\GenericError{#1}{#2}{ERROR}{ERROR}}
\\\\documentclass{$1}[$2]%
\\\\nofiles%
\\\\begin{document}\\\\end{document}" > $CLASSTEST
  (kpsewhich $1.cls && pdflatex -draftmode \
    -output-directory "$WORKING" \
    -halt-on-error $CLASSTEST ) >/dev/null 2>/dev/null
  EXIT=$?
  rm -f $CLASSTEST
  (exit $EXIT)
  return $EXIT
}

_need() {
  WHAT=$1
  PKG=$2
  VERSION=$3
  NAME=$4
  if [ -z "$NAME" ]; then
    NAME="$PKG"
  fi
  if $WHAT "$PKG" "$VERSION"; then
    $ECHO ">> current $NAME found [>=$VERSION]."
    EXIT=1
  else
    EXIT=0
  fi
  (exit $EXIT)
  return $EXIT
}

_need_package() {
  _need _has_package "$@"
}
_need_class() {
  _need _has_class "$@"
}

########################################################################
########################################################################
########################################################################
########################################################################

# REQUIREMENTS

########################################################################
########################################################################
########################################################################
########################################################################
if _need_package "scrbase" "2014/10/28" "KOMA-script"; then
  TDS=`_get_tds "koma-script" ""`
  _deploy_tds $TDS
  $ECHO ">> installed current KOMA-script".
fi

if _need_package "uni-titlepage" "2021/09/01"; then
  $ECHO ">>> Building $PKG, this can take a while, please stand by"
  TDS=`_get_titlepage_github`
  _deploy_tds $TDS
  $ECHO ">> installed current titlepage"
fi

if _need_package "fontaxes" "2011/12/16"; then
  F=fontaxes
  TDS=`_get_ctan $F "pdflatex $F.ins" "" $F.ins $F.pdf README "test-$F.tex=doc/latex/$F"`
  _deploy_tds $TDS
  $ECHO ">> installed current fontaxes"
fi

if _need_package "microtype" "2011/08/18"; then
  TDS=`_get_tds "microtype" ""`
  _deploy_tds $TDS
  $ECHO ">> installed current microtype"
fi

if _need_package "acronym" "2010/09/08"; then
  TDS=`_get_tds "acronym" ""`
  _deploy_tds $TDS
  $ECHO ">> installed current acronym"
fi


if _need_package "newpxmath" "2017/08/18"; then
  TDS=`_get_tds_font "newpx" ""`
  _deploy_tds $TDS
  $ECHO ">> installed current newpx"
fi

if _need_package "ebgaramond" "2013/05/22"; then
  TDS=`_get_tds_font "ebgaramond" ""`
  _deploy_tds $TDS
  $ECHO ">> installed current ebgaramond"
fi

if _need_package "lstlinebgrd" "2012/05/03"; then
  TDS=`_get_tds "lstaddons" ""`
  _deploy_tds $TDS
  $ECHO ">> installed current lstlinebgrd"
fi

if _need_package "babel" "2012/05/16"; then
  $ECHO ">> please update babel"
  exit 1
fi
# EOF
