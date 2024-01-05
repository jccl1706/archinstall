#!/usr/bin/env bash

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR="HDMI-1"

monitor_add() {
	# Move first 7 desktops to external monitor
	for desktop in $(bspc query -D --names -m "$INTERNAL_MONITOR" | sed 7q); do
		bspc desktop "$desktop" --to-monitor "$EXTERNAL_MONITOR"
	done
	# Remove default desktop created by bspwm
	bspc desktop Desktop --remove
	# reorder monitors
	bspc wm -O "$EXTERNAL_MONITOR" "$INTERNAL_MONITOR"
}

monitor_remove() {
	# Add default temp desktop because a minimum of one desktop is required per monitor
	bspc monitor "$EXTERNAL_MONITOR" -a Desktop

	# Move all desktops except the last default desktop to internal monitor
	for desktop in $(bspc query -D -m "$EXTERNAL_MONITOR"); do
		bspc desktop "$desktop" --to-monitor "$INTERNAL_MONITOR"
	done

	# delete default desktops
	bspc desktop Desktop --remove
	# reorder desktops
	bspc monitor "$INTERNAL_MONITOR" -o 󰖟 󰳫        󰊗 
}

if [[ $(xrandr -q | grep "${EXTERNAL_MONITOR} connected") ]]; then
	# set xrandr rules for docked setup
	xrandr --output "$INTERNAL_MONITOR" --mode 1920x1200  --output "$EXTERNAL_MONITOR" --primary --mode 2560x1440  --rate 100 --rotate normal
	if [[ $(bspc query -D -m "${EXTERNAL_MONITOR}" | wc -l) -ne 7 ]]; then
		monitor_add
	fi
	bspc wm -O "$EXTERNAL_MONITOR" "$INTERNAL_MONITOR"
else
	# set xrandr rules for mobile setup
	xrandr --output "$INTERNAL_MONITOR" --primary --mode 1920x1200 --pos 0x0 --rotate normal --output "$EXTERNAL_MONITOR" --off
	if [[ $(bspc query -D -m "${INTERNAL_MONITOR}" | wc -l) -ne 7 ]]; then
		monitor_remove
	fi
fi

# Set wallpaper
#~/.local/bin/setbg.sh &

## set wallpaper ##
feh --bg-scale "$HOME"/.config/wallpapers/000002.png 

# Kill and relaunch polybar
kill -9 $(pgrep -f 'polybar') >/dev/null 2>&1
polybar-msg cmd quit >/dev/null 2>&1
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
if [[ $(xrandr -q | grep "${EXTERNAL_MONITOR} connected") ]]; then
	polybar --reload left -c ~/.config/polybar/config.ini </dev/null >/var/tmp/polybar-left.log 2>&1 200>&- &
	polybar --reload right -c ~/.config/polybar/config.ini </dev/null >/var/tmp/polybar-right.log 2>&1 200>&- &
else
	polybar --reload left -c ~/.config/polybar/config.ini </dev/null >/var/tmp/polybar-left.log 2>&1 200>&- &
fi
