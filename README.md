# SWAThesis #

A LaTeX class for writing theses at
the [Hasso-Plattner-Institut][],
[University of Potsdam][], Germany. 
It has often been used at the [Software Architecture Group][].

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
* The [HPITR][] class
* The [`uni-titlepage`][titlepage] package by Markus Kohm
* A current [`fontaxes`][fontaxes] package for `microtype`
* A current [`acronyms`][acronyms] or [`glossaries`][glossaries] package

The `get_requirements.sh` script installs these automatically, if needed.

## Contents ##

    .
    ├── README.md         — This file
    ├── LICENSE.txt       — The LPPL
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


[Software Architecture Group]: https://www.hpi.uni-potsdam.de/swa
[University of Potsdam]: https://www.uni-potsdam.de
[Hasso-Plattner-Institut]: https://www.hpi.de
[TDS]: https://en.wikipedia.org/wiki/TeX_Directory_Structure "Wikipedia: TDS"
[titlepage]: https://komascript.de/titlepage
[hpitr]: https://github.com/hpi-swa-lab/hpitr
[microtype]: https://ctan.org/pkg/microtype
[fontaxes]: https://ctan.org/pkg/fontaxes
[ctable]: https://ctan.org/pkg/ctable
[acronyms]: https://ctan.org/pkg/acronyms
[glossaries]: https://ctan.org/pkg/glossaries
