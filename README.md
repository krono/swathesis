# SWAThesis #

An unofficial LaTeX class for writing these at
the [Software Architecture Group][], [Hasso-Plattner-Institut][],
[University of Potsdam][], Germany.

This package consists of

* The `swathesis` class
* Supporting style files
* The `swth` script for managing `swathesis` directories

## Usage ##

Simply say

    swth create

and after a few questions, you are rewarded with a nice thesis template.

You can easily compile and your LaTeX file with

    swth go

or care for individual steps with

    swth latex
    swth bibtex
    swth show

A `swth` managed bachelor’s thesis is meant to be multipart, and so you can add
an additional author to it via

    swth author

That are the simple cases. `swth --help` has more information.

## Installation ##

Use the install script like

    ./install.sh [--help …]

or use

    ./tdsify.sh

to generate a [TDS][] compatible package for manual installation.

## Requirements ##

`swathesis` needs

* A current [`microtype`][microtype] version
* The [LNCS][] class LaTeX2e class
* The [`titlepage`][titlepage] package by Markus Kohm (although still alpha)

The `get_requirements.sh` script installs these automatically, if needed.


## Contents ##

    .
    ├── README.md         — This file
    ├── install.sh        — Installation helper
    ├── tdsify.sh         — Packaging helper
    ├── requirements/     — Requirements helper
    ├── bin/swth.sh       — The manager script
    ├── contrib/          — Additional resources, templates for swth
    ├── swathesis.cls     — The class
    ├── swa-*.sty         — The style files
    ├── amd64masm.def     — listing languages
    ├── javascript.def
    ├── lua.def
    ├── smalltalk.def
    └── title-hpi-swa.def — titlepage style


[Software Architecture Group]: http://www.hpi.uni-potsdam.de/swa
[University of Potsdam]: http://www.uni-potsdam.de
[Hasso-Plattner-Institut]: http://www.hpi-web.de
[TDS]: http://en.wikipedia.org/wiki/TeX_Directory_Structure "Wikipedia: TDS"
[titlepage]: http://komascript.de/titlepage
[LNCS]: http://www.springer.com/computer/lncs/lncs+authors
[microtype]: http://mirror.ctan.org/help/Catalogue/entries/microtype.html
