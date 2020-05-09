#!/bin/bash

t=0

toggle() {
    t=$(((t + 1) % 2))
}


trap "toggle" USR1

IS_RUNNING=0
IS_LAUNCHING=0

function launch() {
  sleep 2
  IS_RUNNING=1
  IS_LAUNCHING=0
}

while true; do
    if [[ $t -eq 1 ]]; then

      if [[ $IS_RUNNING -eq 0 ]]; then
        if [[ $IS_LAUNCHING -eq 0 ]]; then
          IS_LAUNCHING=1
          echo " Starting vpn..."
          launch
          echo "VPN ON"
        fi
        echo "Starting..."
      fi
    else
      echo "No VPN"
    fi
    sleep 1 &
    wait
done
