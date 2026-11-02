#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

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
polybar -r -c "$CONF" default &

echo "Polybar launched..."
