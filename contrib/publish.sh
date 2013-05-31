#!/bin/bash

FILE=thesis
PDF_FILE=${FILE}.pdf
TEX_FILE=${FILE}.tex

PUBLIC="/Users/tobias/Downloads/Dropbox/Public/thesis"
JSON="${PUBLIC}/data.js"
WORDS="${PUBLIC}/words.part"
PAGES="${PUBLIC}/pages.part"

if [ ! -f ${PDF_FILE} ];
then
  exit 1;
# ./make.sh
fi

# publish stuff

DATE=$(date +%s)

PDFTOTEX_COUNT_1=$(pdftotext  -nopgbrk ${PDF_FILE} - | wc -w)
PDFTOTEX_COUNT_2=$(pdftotext -raw -nopgbrk ${PDF_FILE} - | wc -w)
PDFTOTEX_COUNT_3=$(pdftotext -layout -nopgbrk ${PDF_FILE} - | wc -w)
(( PDFTOTEX_COUNT = (${PDFTOTEX_COUNT_1} +  ${PDFTOTEX_COUNT_2} + ${PDFTOTEX_COUNT_3}) / 3 ))
DETEX_COUNT=$(detex ${TEX_FILE} | wc -w)
(( WORD_COUNT_MEAN = (${PDFTOTEX_COUNT} + 4 * ${DETEX_COUNT}) / 5 ))

PAGE_COUNT=$(pdfinfo ${PDF_FILE} | grep Pages | awk '{ printf "%s", $2 }') 

echo "{x: ${DATE}, y: ${WORD_COUNT_MEAN} }," >> ${WORDS}
echo "{x: ${DATE}, y: ${PAGE_COUNT} }," >> ${PAGES}

# words
echo "var words = [" > ${JSON}
cat ${WORDS} >> ${JSON}
echo "]" >> ${JSON}

# pages
echo "var pages = [" >> ${JSON}
cat ${PAGES} >> ${JSON}
echo "]" >> ${JSON}

# thumbnails
convert thesis.pdf -alpha off -resize '60' ${PUBLIC}/images/thumbnail.png

EXIT=$?

echo "There are ${WORD_COUNT_MEAN}  (${PDFTOTEX_COUNT}, ${DETEX_COUNT}) on ${PAGE_COUNT} pages"

exit $EXIT;

