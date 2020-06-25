#!/bin/bash
IFS=$'\n'
WINDOWS=($(xdotool search --all --onlyvisible --name .+))

for w in ${WINDOWS[@]}
do
	check=$(xdotool getwindowgeometry $w | grep "1920x1080" )
	if [ $check ]
	then
		pid=$(xdotool getwindowpid $w)
		if [ $pid ]
		then
			echo $w
			echo name: $(xdotool getwindowname $w)
			geom=$(xdotool getwindowgeometry $w)
			regex=".+Position: ([0-9]+),([0-9]+).+Geometry: ([0-9]+)x([0-9]+)"
			if [[ $geom =~ $regex ]]
			then
				x=${BASH_REMATCH[1]}
				y=${BASH_REMATCH[2]}
				w=${BASH_REMATCH[3]}
				h=${BASH_REMATCH[4]}
				#todo: make this dynamic
				if [ $x -gt 0 && $x -lt 1920 ]
				then
					kill $(cat /tmp/POLYBAR_BOTTOM_DP-2)
					rm '/tmp/POLYBAR_BOTTOM_DP-2'
					kill $(cat /tmp/POLYBAR_TOP_DP-2)
					rm '/tmp/POLYBAR_TOP_DP-2'
				else
					kill $(cat /tmp/POLYBAR_BOTTOM_DVI-D-0)
					rm '/tmp/POLYBAR_BOTTOM_DVI-D-0'
					kill $(cat /tmp/POLYBAR_TOP_DVI-D-0)
					rm '/tmp/POLYBAR_TOP_DVI-D-0'
				fi
				echo pos: ${BASH_REMATCH[1]}, ${BASH_REMATCH[2]}
				echo siz: ${BASH_REMATCH[3]} x ${BASH_REMATCH[4]}
			fi
		#else
			#echo remosjhkfjhdsfjkhdslfjkhdsl
		fi
	fi
done
