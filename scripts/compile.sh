#!/bin/bash

source scripts/utils.sh
source theme.sh

TEMPLATE_FILES=$(find dot config -name '*.template')
TEMPLATE_FILES_NB=$(echo $TEMPLATE_FILES | wc -l)

TMP_FILE=$(mktemp)

for TEMPLATE_FILE in $TEMPLATE_FILES; do
  DIRNAME=$(dirname -- "$TEMPLATE_FILE")
  FILENAME=$(basename -- "$TEMPLATE_FILE")
  TRIMMED="${FILENAME%.*}"
  TARGET="$DIRNAME/$TRIMMED"

  cp $TEMPLATE_FILE $TMP_FILE
  sed --in-place "s/$\[DPI\]/$DPI/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_FOREGROUND\]/$COLOR_FOREGROUND/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_FOREGROUND\]/$COLOR_FOREGROUND/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_BACKGROUND\]/$COLOR_BACKGROUND/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_CURSOR\]/$COLOR_CURSOR/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR0\]/$COLOR_COLOR0/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR1\]/$COLOR_COLOR1/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR2\]/$COLOR_COLOR2/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR3\]/$COLOR_COLOR3/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR4\]/$COLOR_COLOR4/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR5\]/$COLOR_COLOR5/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR6\]/$COLOR_COLOR6/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR7\]/$COLOR_COLOR7/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR8\]/$COLOR_COLOR8/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR9\]/$COLOR_COLOR9/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR10\]/$COLOR_COLOR10/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR11\]/$COLOR_COLOR11/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR12\]/$COLOR_COLOR12/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR13\]/$COLOR_COLOR13/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR14\]/$COLOR_COLOR14/g" $TMP_FILE
  sed --in-place "s/$\[COLOR_COLOR15\]/$COLOR_COLOR15/g" $TMP_FILE
  cp $TMP_FILE $TARGET

  LOG "compiled $TARGET"
done

rm $TMP_FILE
LOG "compile success"
