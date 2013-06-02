#!/bin/sh
#
# swth.sh -- create or manage theses for swathesis
#
#

#set -x
VERSION="0.1"
PROGRAM=`echo $0 | sed 's%.*/%%'`
ECHO="/bin/echo -e"

USAGE="Usage: $PROGRAM [OPTIONS] COMMAND

Create or manage swathesis documents.


OPTIONS
  --bachelor operate in BSc mode
  --master   operate in MSc mode
  --phd      operate in PHd mode

  --xe       use XeLaTeX
  --pdf      use PDFLaTeX (default)
  --lua      use LuaLaTeX
  --biber    use Biber instead of Bibtex

  --help     output this help and exit
  --dry-run  don't execute, just say what would be
  --version  output version information and exit

COMMAND

  create     create swathesis document
  init       put directory under $PROGRAM management

  bibtex     run bibtex [especially for BSc mode]
  latex      run latex (honors OPTIONS and management file)
  show       open result document
  clean      clean auxiliary files
  go         short for latex; bibtex; latex; latex; latex; show

  author     add another author in BSc mode

"

$ECHO "Beware of Dragons!"

MODE=
DRY=false
MAIN=

BIBTEX=bibtex
LATEX=pdflatex
RM=rm
MKDIR="mkdir -p"
CP=cp
MV=mv
SED=sed

THESESMARKER="%SWTH_do_not_remove"

_T=`kpsewhich swathesis.cls`
if test "x$_T" = "x"; then
  $ECHO "$PROGRAM: cannot find swathesis"
  exit 200
fi
TEMPLATEROOT="`dirname $_T`/contrib"

if test -z "$OSTYPE" ; then
  OSTYPE=`uname -s | tr A-Z a-z`
fi

if type pushd 2>/dev/null >/dev/null ; then
  : #ok, pushd is there
else
  # emulate pushd to our usage
  pushd() {
    export P_OLDPWD="$PWD"
    cd $1
  }
  popd() {
    if test "x$P_OLDPWD" = x; then
      $ECHO "$0: directory stack empty"
      (exit 1)
      return 1
    else
      cd "$P_OLDPWD"
      export P_OLDPWD=
    fi
  }
fi


case "$OSTYPE" in
  cygwin)
    OPEN="cygstart"
    RM="del"
    MKDIR="md"
    CP="copy"
    MV="move"
    ;;
  solaris*) OPEN="xdg-open" ;;
  bsd*)     OPEN="xdg-open" ;;
  linux)    OPEN="xdg-open" ;;
  darwin*)
    OPEN="open"
    SKIM="net.sourceforge.skim-app.skim"
    HAS_SKIM=`mdfind "kMDItemCFBundleIdentifier == 'net.sourceforge.skim-app.skim'"`
    if test "x$HAS_SKIM" != "x"; then
      OPEN="$OPEN -b $SKIM"
    fi
    ;;
  *)
    $ECHO "Warn: cannot provide open. \`show' won't work."
    OPEN=$ECHO
    ;;
esac

_clean() {
  $RM -f *.log *.aux *.aut *.out *.toc *.synctex.gz *.bbl *.blg *.lol *.loc *.lot *.loa *.idx *.ind *.ilg *.glo *.gls *.glg *.fdb_latexmk *.run.xml *.bcf *.lof *.tdo
  $RM -f */*.log */*.aux */*.aut */*.out */*.toc */*.synctex.gz */*.bbl */*.blg */*.lol */*.loc */*.lot */*.loa */*.idx */*.ind */*.ilg */*.glo */*.gls */*.glg */*.fdb_latexmk */*.run.xml */*.bcf */*.lof */*.tdo
}

__readmode() {
  if test "x$MODE" = "x"; then
    printf "$1 [BACHELOR|master|phd] "
    read ANS
    case "$ANS" in
      [Mm][Ss][Cc]|[Mm][Aa][Ss]*) MODE=master   ;;
      [Pp][Hh][Dd])               MODE=phd      ;;
      *)                          MODE=bachelor ;;
    esac
  fi
  TEMPLATEDIR="$TEMPLATEROOT/${MODE}_template"
}

__readdir() {
  printf "$1 [$PWD] "
    read ANS
    if test "x$ANS" = "x"; then
      SWTHDIR=$PWD
    else
      SWTHDIR=$ANS
    fi
}

__readmain_bp() {
  if test `date +"%m"` -gt 9; then
    YEAR=`date +"%Y"`
  else
    if date -v >/dev/null 2>/dev/null; then
      # this worked, ie, this is GNU date
      YEAR=`date --date="1 year ago"`
    else
      # this is POSIX date
      YEAR=`date -v-1y +"%Y"`
    fi
  fi
  BP=
  while test "x$BP" = "x"; do
    printf "What is your bachelor project number (eg, H1)? "
    read BP
    BP=`$ECHO "$BP" | sed -e 's%[ ,./!?]%%g'`
  done
  MAIN="BP${YEAR}${BP}_Theses"
}


__ask_for_main() {
  YEAR=`date +"%Y"`
  NAME=
  while test "x$NAME" = "x"; do
    printf "What is your family name? "
    read NAME
    NAME=`$ECHO "$NAME" | sed -e 's%[ ,./!?]%%g'`
  done
  TITLE=
  if test "x$TITLE" = "x"; then
    printf "Pleas give a short title or leave blank: "
    read TITLE
    if test "x$TITLE" = "x"; then
      TITLE=Thesis
    fi
  fi
  $ECHO "${NAME}_${YEAR}_${TITLE}"
}

__readmain() {
  if test "x$MODE" = "xbachelor"; then
    printf "Use HPI Bachelor Project information? [NO/yes] "
    read ANS
    case "$ANS" in
      [Yy]|[Yy][Ee][Ss]*)
        __readmain_bp
        return
        ;;
      *) ;;
    esac
  fi
  MAIN=`__ask_for_main`
}


__copy_template() {
  DFLT=TEMPLATE
  $CP -r "$TEMPLATEDIR/" "$SWTHDIR"
  $MV "${DFLT}.tex" "${MAIN}.tex"
  $MV "${DFLT}-names.tex" "${MAIN}-names.tex"
}


_create() {
  if test "x$SWTHFILE" != "x" && test -f "$SWTHFILE"; then
    printf "Already configured, really continue? [NO/yes] "
    read ANS
    if test "x$ANS" = "xyes" || test "x$ANS" = "xYes" || test "x$ANS" = "xYES" || test "x$ANS" = "xy" || test "x$ANS" = "xY"; then
      :
    else
      $ECHO "aborting"
      exit 4
    fi
  fi
  __readmode "What thesis do you want to create?"
  __readdir "Where do you want to create?"
  if test -d $SWTHDIR; then
    $ECHO "Found $SWTHDIR"
  else
    printf "$SWTHDIR does not yet exist, create? [YES/no]"
    read $ANS
    case "x$ANS" in
      x[Nn][Oo]?) ;;
      *) $MKDIR $SWTHDIR ;;
    esac
  fi
  if test "x$MODE" != "xbachelor" ; then
    __set_biber
  fi
  _init
  __copy_template
}

_init() {
  __readmode "What thesis do you have?"
  __readmain
  if test "x$SWTHFILE" = "x"; then
    SWTHFILE=$SWTHDIR/.swth
  fi
  if test "x$DRY" != "xtrue"; then
    : > $SWTHFILE
    printf "# swth config file\n" >> $SWTHFILE
    printf "MODE=$MODE\n"         >> $SWTHFILE
    printf "LATEX=$LATEX\n"       >> $SWTHFILE
    printf "BIBTEX=$BIBTEX\n"     >> $SWTHFILE
    printf "MAIN=$MAIN\n"         >> $SWTHFILE
  fi
}

__set_biber() {
  if type biber 2>/dev/null >/dev/null; then
    $ECHO "Using Biber for BibTeX"
    BIBTEX=biber
  fi
}

_bibtex() {
  if test "$MODE" = "bachelor"; then
    find "$SWTHDIR" -mindepth 2 -name \*.aux | while read FILENAME; do
      dir=`dirname "$FILENAME"`;
      base=`basename "$FILENAME" | sed -E -e 's/\.aux$//'`
      pushd $dir 2>/dev/null >/dev/null;
        $BIBTEX $base "$@"
      popd 2>/dev/null >/dev/null;
    done
  elif test "x$MAIN" != "x"; then
    $BIBTEX $MAIN "$@"
  else
    $BIBTEX "$@"
  fi
}

_latex() {
  if test "x$MAIN" != "x"; then
    $LATEX "$@" $MAIN
  else
    $LATEX "$@"
  fi
}

_show() {
  if test "x$MAIN" = "x"; then
    $ECHO "No main file. Forgot \`$PROGNAME init'?"
    exit 3
  else
    $OPEN $PDFOUT
  fi
}

_go() {
  _latex && _bibtex && _latex && _latex && _latex && _show
}

_author() {
  if test "x$MODE" != "xbachelor"; then
    $ECHO "$PROGRAM: adding an author outside BSc mode is not meaningful, aborting"
    exit 5;
  fi
  AU_TEMPLATEDIR="$TEMPLATEROOT/Author_template"
  AUTHOR=
  while test "x$AUTHOR" = "x"; do
    printf "Please name the author to add: "
    read AUTHOR
    AUTHOR=`$ECHO "$AUTHOR" | sed -e 's%[ ,./!?]%%g'`
  done
  AU_DIR="$SWTHDIR/$AUTHOR"
  if test -d "$AU_DIR"; then
    $ECHO "$PROGRAM: $AUTHOR directory already exists, don't know what to do, aborting"
    exit 6
  fi
  $CP -r "$AU_TEMPLATEDIR" "$AU_DIR"
  AU_MAIN=`__ask_for_main`
  $MV "$AU_DIR/TEMPLATE.tex" "$AU_DIR/${AU_MAIN}.tex"

  if grep -q "$THESESMARKER" "$SWTHDIR/${MAIN}.tex" 2>/dev/null >/dev/null; then
    sed -i.bak -E -e "s!$THESESMARKER!$AUTHOR,$THESESMARKER!" "$SWTHDIR/${MAIN}.tex"
  else
    $ECHO "$PROGRAM: Cannont find Thesesmarker \`$THESESMARKER' in $MAIN, you're on your own."
  fi
}

# process .swth file here or in parent (one dir up)
SWTHDIR=$PWD
SWTHFILE=
if test -f ./.swth; then
  SWTHFILE=./.swth
  . $SWTHFILE
else
  if test -f ../.swth; then
    SWTHDIR=`dirname $PWD`
    SWTHFILE=../.swth
    . $SWTHFILE
  fi
fi


if test "x$MAIN" != "x"; then
  PDFOUT=$MAIN.pdf
fi

#
# help if nothing specified
#
if test $# -lt 1; then
    set -- --help
fi

while test $# -gt 0; do
  if test "x$1" = x--help || test "x$1" = x-help || test "x$1" = x-h; then
    $ECHO "$USAGE"
    exit 0
  elif test "x$1" = x--version || test "x$1" = x-version; then
    $ECHO "$PROGRAM $VERSION"
    exit 0
  elif test "x$1" = x--verbose || test "x$1" = x-verbose; then
    VERBOSE=true
  elif test "x$1" = x--dry-run || test "x$1" = x-n; then
    DRY=true
  elif test "x$1" = x--bachelor; then
    MODE=bachelor
  elif test "x$1" = x--master; then
    MODE=master
  elif test "x$1" = x--phd; then
    MODE=phd
  elif test "x$1" = x--xe; then
    LATEX=xelatex
  elif test "x$1" = x--pdf; then
    LATEX=pdflatex
  elif test "x$1" = x--lua; then
    LATEX=lualatex
  elif test "x$1" = x--biber; then
    __set_biber
  elif $ECHO "x$1" | grep '^x-' >/dev/null >/dev/null; then
    $ECHO "$PROGRAM: unknown option \`$1', try --help if you need it." >&2
    exit 1
  else
    break
  fi
  shift
done

if test $# -lt 1; then
  $ECHO "$PROGRAM: no command specified, try --help." >&2
  exit 2
fi

if test "x$DRY" = "xtrue"; then
  RM="$ECHO $RM"
  MKDIR="$ECHO $MKDIR"
  CP="$ECHO $CP"
  MV="$ECHO $MV"
  SED="$ECHO $SED"
  OPEN="$ECHO $OPEN"
  LATEX="$ECHO $LATEX"
  BIBTEX="$ECHO $BIBTEX"
fi


if test "x$VERBOSE" = "xtrue"; then
  $ECHO "\
Information
===========
MAIN = $MAIN
MODE = $MODE
SWTHDIR = $SWTHDIR
.swth = $SWTHFILE

DRY = $DRY
PDFOUT = $PDFOUT

LATEX = $LATEX
BIBTEX = $BIBTEX
OPEN = $OPEN

TEMPLATEROOT = $TEMPLATEROOT
TEMPLATEDIR = $TEMPLATEDIR
command = $1"

fi

pushd "$SWTHDIR" >/dev/null 2>/dev/null

case "x$1" in
    xcreate) _create ;;
    xclean)  _clean ;;
    xinit)   _init ;;
    xbibtex) _bibtex ;;
    xlatex)  _latex ;;
    xshow)   _show ;;
    xgo)     _go ;;
    xauthor) _author ;;
    *)
        $ECHO "$PROGRAM: unknown command \`$1', try --help if you need it." >&2
        exit 2
        ;;
esac
EXIT=$?

popd 2>/dev/null >/dev/null

if test $EXIT -ne 0; then
  $ECHO "Whoops"
else
  $ECHO "Done"
fi
