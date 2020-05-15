#!/bin/bash

t=0

toggle() {
  if [[ $IS_STOPPING -eq 1 ]] || [[ $IS_LAUNCHING -eq 1 ]]; then
    return
  fi
  t=$(((t + 1) % 2))
}


trap "toggle" USR1

IS_RUNNING=0
IS_LAUNCHING=0
IS_STOPPING=0

function startvpn() {
  IS_LAUNCHING=1
  echo "   Starting vpn...  "
  /home/meri/bin/startvpn
  IS_RUNNING=1
  IS_LAUNCHING=0
}

function stopvpn() {
  IS_STOPPING=1
  echo "   Stopping vpn...  "
  /home/meri/bin/stopvpn
  IS_RUNNING=0
  IS_STOPPING=0
}

while true; do
  if [[ $t -eq 1 ]]; then

    # TOGGLE ON

    if [[ $IS_RUNNING -eq 0 ]]; then
      if [[ $IS_LAUNCHING -eq 0 ]]; then
        startvpn
      fi
    fi
    echo "%{B#263E32}  歷 VPN ON  %{B-}"

  else

    # TOGGLE OFF

    if [[ $IS_RUNNING -eq 1 ]]; then
      if [[ $IS_STOPPING -eq 0 ]]; then
        stopvpn
      fi
    fi
    echo "  歷 VPN OFF  "

  fi

  sleep 1 &
  wait
done
