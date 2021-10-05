#!/bin/sh
set -e

if [ ! -z "$ZSH_VERSION" ]; then
  setopt shwordsplit
fi
ECHO="/usr/bin/printf %b\\n"

if type zip >/dev/null 2>/dev/null; then
    :
else
    $ECHO ">> \`zip' not found, please install."
    exit 1
fi


TEX=tds/tex/latex/swathesis
BIN=tds/scripts/swathesis
DOC=tds/doc/latex/swathesis
MAN=tds/doc/man/man1
INFO=tds/doc/info

if [ ! -d "$TEX" ]; then mkdir -p "$TEX"; fi
cp -R contrib *.sty *.def *.cls swa-*.tex "$TEX"

if [ ! -d "$BIN" ]; then mkdir -p "$BIN"; fi
cp swth "$BIN"

if [ ! -d "$DOC" ]; then mkdir -p "$DOC"; fi
cp  swth.pdf swth.tex "$DOC"

if [ ! -d "$MAN" ]; then mkdir -p "$MAN"; fi
cp swth.1 "$MAN"

if [ ! -d "$INFO" ]; then mkdir -p "$INFO"; fi
cp swth.info "$INFO"


find tds -name .DS_Store -delete
cd tds
zip -r -q -X ../swathesis.tds.zip *

# EOF
