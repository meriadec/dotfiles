#!/bin/bash

killall feh 2>/dev/null
feh -x -Z -R 1 colors.png &

hotreload theme.sh scripts/build-colors.sh <<EOF
  make colors
EOF
