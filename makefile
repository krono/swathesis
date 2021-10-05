SWTH:=swth
TDS:=swathesis.tds.zip

.PHONY: default zip docs ctan

default:
	@./swth dragons

zip: $(TDS)

docs:  $(SWTH).1 $(SWTH).pdf $(SWTH).info

CTAN_STUFF= \
  DEPENDS.txt README.md \
  *.sty *.def *.cls swa-*.tex \
  contrib swth.pdf swth.tex \
  swth swth.1 swth.info 

ctan: docs
	mkdir -p ctan-out
	cp -r $(CTAN_STUFF) ctan-out

$(TDS): *.sty *.cls *.def *.tex docs
	./tdsify.sh

$(SWTH).pdf: $(SWTH).tex
	lualatex $(SWTH).tex

$(SWTH).1: $(SWTH).tex
	latex2man -M $< $@

$(SWTH).texi: $(SWTH).tex
	latex2man -t ./latex2man.trans -T $< $@

$(SWTH).info: $(SWTH).texi
	LC_ALL=C /usr/bin/makeinfo $<

