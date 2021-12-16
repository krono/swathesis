# Individual Bachelor’s Thesis #

This is the thesis directory for your own thesis.

Compile it via

    pdflatex TEMPLATE

You can compile all theses together with `swth go`, `swth latex`, or similar, but
this will generate the combined document in the parent directory.

## Files ##
    .
    ├── README.md       # this file
    ├── content.tex     # put your thesis content here
    ├── references.bib  # put your references here
    ├── system.tex      # put your packages and configuration her
    └── TEMPLATE.tex    # compile this file to generate your individual thesis

The files `content.tex`, `references.bib`, and `system.tex` are automatically picked up by the parent directory TeX source.
Please _do not change_ `TEMPLATE.tex` if you want these changes to be also available in the combined document.