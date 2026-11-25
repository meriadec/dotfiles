#!/bin/bash

function LOG {
  COLOR=33
  PREFIX='[.] '
  if [ "$2" == "success" ]; then
    COLOR=35
    PREFIX='[✔] '
  fi
  printf "\e[1;${COLOR}m ${PREFIX} %-6s\e[m\n" "$1"
}
