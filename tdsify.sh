#!/bin/sh


TEX=tds/tex/latex/swathesis
BIN=tds/scripts/swathesis

if [ ! -d "$TEX" ]; then mkdir -p "$TEX"; fi
cp -r contrib *.sty *.def *.cls "$TEX"

if [ ! -d "$BIN" ]; then mkdir -p "$BIN"; fi
cp bin/* "$BIN"

cd tds
if which zip >/dev/null; then
    zip -r -q -X ../swathesis.tds.zip *
else
    echo "> You need to install 'zip'." >&2
    exit 1
fi
