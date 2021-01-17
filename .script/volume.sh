#!/bin/sh

polybar-msg cmd show
xdo raise -a "polybar-level_DVI-D-0"

sleep 5

[ "$(pidof -x $0 | wc -w)" -le "2" ] \
	&& polybar-msg cmd hide

