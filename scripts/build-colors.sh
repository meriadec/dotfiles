#!/bin/bash

source scripts/utils.sh
source theme.sh

rm -rf .tmp
mkdir .tmp

SIZE='100x100'

LOG 'building colors...'
NOW=`TIMESTAMP`

convert -size $SIZE canvas:$COLOR_FOREGROUND .tmp/01_FOREGROUND.png
convert -size $SIZE canvas:$COLOR_BACKGROUND .tmp/02_BACKGROUND.png

convert -size $SIZE canvas:$COLOR_CURSOR .tmp/03_CURSOR.png

convert -size $SIZE canvas:$COLOR_COLOR0 .tmp/04_COLOR0.png
convert -size $SIZE canvas:$COLOR_COLOR1 .tmp/05_COLOR1.png
convert -size $SIZE canvas:$COLOR_COLOR2 .tmp/06_COLOR2.png
convert -size $SIZE canvas:$COLOR_COLOR3 .tmp/07_COLOR3.png
convert -size $SIZE canvas:$COLOR_COLOR4 .tmp/08_COLOR4.png
convert -size $SIZE canvas:$COLOR_COLOR5 .tmp/09_COLOR5.png
convert -size $SIZE canvas:$COLOR_COLOR6 .tmp/10_COLOR6.png
convert -size $SIZE canvas:$COLOR_COLOR7 .tmp/11_COLOR7.png
convert -size $SIZE canvas:$COLOR_COLOR8 .tmp/12_COLOR8.png
convert -size $SIZE canvas:$COLOR_COLOR9 .tmp/13_COLOR9.png
convert -size $SIZE canvas:$COLOR_COLOR10 .tmp/14_COLOR10.png
convert -size $SIZE canvas:$COLOR_COLOR11 .tmp/15_COLOR11.png
convert -size $SIZE canvas:$COLOR_COLOR12 .tmp/16_COLOR12.png
convert -size $SIZE canvas:$COLOR_COLOR13 .tmp/17_COLOR13.png
convert -size $SIZE canvas:$COLOR_COLOR14 .tmp/18_COLOR14.png
convert -size $SIZE canvas:$COLOR_COLOR15 .tmp/19_COLOR15.png

convert -label %t .tmp/* -frame 1x1+0+0 miff:- |\
  montage - -tile x2 -geometry '150x150+0+0>' colors.png

DIFF=`MSDIFF $NOW`
LOG "created colors.png ($DIFF)"
