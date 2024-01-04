#!/bin/bash

[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

## start bspwm window manager
exec bspwm
