# Bachelors’ Theses #

This is the  directory for your combined document of bachelors’ theses.

Compile it via

    swth go

or similar, see `swth --help`.

## Add an individual author ##

To add an author to the combined document, use `swth`:

    swth auhtor
    
This will generate and populate a subdirectory with necessary files, and will change `TEMPLATE.tex` to automatically include it in the combined document.


## Files ##

    .
    ├── README.md            # this file
    ├── TEMPLATE-names.tex   # automatically imported file for hyphenations etc.
    ├── TEMPLATE.tex         # main file for combined document
    └── common
        ├── bibliography.bib # references for the common document parts (eg, the preface)
        ├── document.tex     # governs the setting of common document parts (title, lists, preface...)
        ├── preface.tex      # if the combined document should have a preface, put it here
        ├── style.tex        # global stylistic change (eg, colors)
        ├── system.tex       # global packages and patches
        └── trailer.tex      # parts for the end of the combined document (appendices, affidavits)
