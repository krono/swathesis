#!/bin/bash

###################################################
# CHANGE ACCORDINGLY
###################################################

FILE=thesis
PDF_FILE=${FILE}.pdf
TEX_FILE=${FILE}.tex


RESEARCHER_NAME=CHANGEME
RESEARCHER_KIND=Researcher

FIRST_DAY=2012-01-01
EXPECTED_END=2012-06-30


PUBLIC="${PUBLIC:-/CHANGEME/Dropbox/Public/thesis}"

# PRONOUN
HOW_I_ROLL=she
# POSSESIVE
HOW_I_HIT=her
# OBJECTIVE (her/him/them)
HOW_I_HOLLA=her

###################################################
# (That should be it)
###################################################


TARGET_WORDS=25000
TARGET_PAGES=80

JSON="${PUBLIC}/data.js"
WORDS="${PUBLIC}/words.part"
PAGES="${PUBLIC}/pages.part"


if [ ! -f ${PDF_FILE} ];
then
  echo "${PDF_FILE} not found"
  exit 1;
# ./make.sh
fi

# publish stuff

DATE=$(date +%s)
START_DATE=$(date -j -f "%Y-%m-%d|%H:%M:%S" "${FIRST_DAY}|00:00:00" "+%s")
END_DATE=$(date -j -f "%Y-%m-%d|%H:%M:%S" "${EXPECTED_END}|23:59:59" "+%s")

PDFTOTEX_COUNT_1=$(pdftotext  -nopgbrk ${PDF_FILE} - | wc -w)
PDFTOTEX_COUNT_2=$(pdftotext -raw -nopgbrk ${PDF_FILE} - | wc -w)
PDFTOTEX_COUNT_3=$(pdftotext -layout -nopgbrk ${PDF_FILE} - | wc -w)
(( PDFTOTEX_COUNT = (${PDFTOTEX_COUNT_1} +  ${PDFTOTEX_COUNT_2} + ${PDFTOTEX_COUNT_3}) / 3 ))
DETEX_COUNT=$(detex ${TEX_FILE} | wc -w)
(( WORD_COUNT_MEAN = (${PDFTOTEX_COUNT} + 4 * ${DETEX_COUNT}) / 5 ))

PAGE_COUNT=$(pdfinfo ${PDF_FILE} | grep Pages | awk '{ printf "%s", $2 }') 

echo "{x: ${DATE}, y: ${WORD_COUNT_MEAN} }," >> ${WORDS}
echo "{x: ${DATE}, y: ${PAGE_COUNT} }," >> ${PAGES}

# OUT
echo ";" >${JSON}

# words
echo "var words = [" >>${JSON}
cat ${WORDS} >> ${JSON}
echo "];" >> ${JSON}
echo "var targetWords = ${TARGET_WORDS};" >> ${JSON}

# pages
echo "var pages = [" >> ${JSON}
cat ${PAGES} >> ${JSON}
echo "];" >> ${JSON}
echo "var targetPages = ${TARGET_PAGES};" >> ${JSON}

# dates, names n stuff
echo "var firstDay = ${START_DATE};" >> ${JSON}
echo "var expectedEnd = ${END_DATE};" >> ${JSON}
echo "var theName = '${RESEARCHER_NAME}';"  >> ${JSON}
echo "var theGame = '${RESEARCHER_KIND}';"  >> ${JSON}
echo "var theThing = '${HOW_I_ROLL}';" >> ${JSON}
echo "var theOwn = '${HOW_I_HIT}';" >> ${JSON}
echo "var theStuff = '${HOW_I_HOLLA}';" >> ${JSON}

# thumbnails
convert ${PDF_FILE} -alpha off -resize '60' ${PUBLIC}/images/thumbnail.png

EXIT=$?

echo "There are ${WORD_COUNT_MEAN}  (${PDFTOTEX_COUNT}, ${DETEX_COUNT}) on ${PAGE_COUNT} pages"

exit $EXIT;
# I hate JavaScript

