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

if [ ! -d "$TEX" ]; then mkdir -p "$TEX"; fi
cp -r contrib *.sty *.def *.cls swa-*.tex "$TEX"

if [ ! -d "$BIN" ]; then mkdir -p "$BIN"; fi
cp bin/* "$BIN"

cd tds
zip -r -q -X ../swathesis.tds.zip *

