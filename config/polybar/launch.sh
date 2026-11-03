#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down (force kill after 5 seconds)
for _ in 1 2 3 4 5; do
  pgrep -u $UID -x polybar >/dev/null || break
  sleep 1
done
if pgrep -u $UID -x polybar >/dev/null; then
  killall -q -9 polybar
  sleep 1
fi

# Scale sizes with Xft.dpi (96 = 100%)
DPI=$(xrdb -query | awk '/^Xft.dpi:/ {print $2}')
DPI=${DPI:-96}
scale() { echo $(( $1 * DPI / 96 )); }
export POLYBAR_HEIGHT=$(scale 32) POLYBAR_BORDER=$(scale 5)
# Polybar cannot expand env vars inside font strings: render a config copy.
CONF=${XDG_RUNTIME_DIR:-/tmp}/polybar-config
sed -e "s/@FONT_9@/$(scale 9)/g" -e "s/@FONT_12@/$(scale 12)/g" \
    -e "s/@FONT_15@/$(scale 15)/g" -e "s/@FONT_18@/$(scale 18)/g" \
    "$HOME/.config/polybar/config" > "$CONF"

# Launch Polybar, using default config location ~/.config/polybar/config
# setsid: detach from the caller (e.g. autorandr.service) so it does not keep the unit alive.
setsid -f polybar -r -c "$CONF" default >/dev/null 2>&1 < /dev/null

echo "Polybar launched..."
