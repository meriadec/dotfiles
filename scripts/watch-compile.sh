#!/bin/bash

hotreload \
  scripts/compile.sh \
  dot/*.template \
  config/**/*.template \
<<EOF
  make compile
EOF
