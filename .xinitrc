#!/bin/bash

[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

## my scripts folder
export PATH="$HOME/.config/.scripts:$PATH"
export PATH="$HOME/.config/bspwm/scripts:$PATH"

## start bspwm window manager
exec bspwm
