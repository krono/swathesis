# swathesis #

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

`swathesis` needs, among others,

* The [HPITR][hpitr] class
* The [KOMA-Script][koma-script] bundle by Markus Kohm
* The [`uni-titlepage`][uni-titlepage] package by Markus Kohm
* A current [`microtype`][microtype] version
* A current [`fontaxes`][fontaxes] package for `microtype`
* A current [`acronyms`][acronyms] or [`glossaries`][glossaries] package

See [DEPENDS.txt](DEPENDS.txt) for an exhaustive list of requires packages

## Contents ##

    .
    ├── README.md             — This file
    ├── LICENSE.txt           — The LPPL
    ├── DEPENDS.txt           — List of necessary packges
    ├── install.sh            — Installation helper
    ├── tdsify.sh             — Packaging helper
    ├── bin/swth.sh           — The manager script
    ├── contrib/              — Additional resources, templates for swth
    ├── swathesis.cls         — The class
    ├── swa-*.sty             — The style files
    ├── amd64masm.def         — listing languages
    ├── javascript.def
    ├── lua.def
    ├── smalltalk.def
    ├── title-hpi-swa.def     — uni-titlepage style
    └── title-hpi-swa-phd.def — uni-titlepage style for PhD theses


[Software Architecture Group]: https://www.hpi.uni-potsdam.de/swa
[University of Potsdam]: https://www.uni-potsdam.de
[Hasso-Plattner-Institut]: https://www.hpi.de
[TDS]: https://en.wikipedia.org/wiki/TeX_Directory_Structure "Wikipedia: TDS"
[uni-titlepage]: https://ctan.org/pkg/uni-titlepage
[koma-script]: https://ctan.org/pkg/koma-script
[hpitr]: https://github.com/hpi-swa-lab/hpitr/releases/latest
[microtype]: https://ctan.org/pkg/microtype
[fontaxes]: https://ctan.org/pkg/fontaxes
[acronyms]: https://ctan.org/pkg/acronyms
[glossaries]: https://ctan.org/pkg/glossaries
