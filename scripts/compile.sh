#!/bin/bash

source theme.sh

TEMPLATE_FILES=$(find dot config -name '*.template')
TEMPLATE_FILES_NB=$(echo $TEMPLATE_FILES | wc -l)

for TEMPLATE_FILE in $TEMPLATE_FILES; do
  DIRNAME=$(dirname -- "$TEMPLATE_FILE")
  FILENAME=$(basename -- "$TEMPLATE_FILE")
  TRIMMED="${FILENAME%.*}"
  TARGET="$DIRNAME/$TRIMMED"
  sed "s/$\[DPI\]/$DPI/g" $TEMPLATE_FILE > $TARGET
  echo "> compiled $TARGET"
done
