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

function TIMESTAMP {
  date +%s.%N
}

function MSDIFF {
  STARTTIME=$1
  ENDTIME=`TIMESTAMP`
  TIMEDIFF=`echo "$ENDTIME - $STARTTIME" | bc | awk -F"." '{ print $1 substr($2,1,3) "ms" }'`
  echo $TIMEDIFF
}
