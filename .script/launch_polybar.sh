#!/bin/bash
bars=$(ls /tmp/ | grep POLYBAR)

index=0
for m in $(polybar --list-monitors | cut -d":" -f1); do
	if [ -e "/tmp/POLYBAR_TOP_$m" ]
	then
		echo "POLYBAR TOP already exists for $m"
	else
    		MONITOR=$m polybar --reload top & echo $! > "/tmp/POLYBAR_TOP_$m"
	fi
	
	if [ -e "/tmp/POLYBAR_BOTTOM_$m" ]
	then
		echo "POLYBAR BOTTOM already exists for $m"
	else
    		MONITOR=$m polybar --reload bottom & echo $! > "/tmp/POLYBAR_BOTTOM_$m"
	fi
    #MONITOR=$m polybar --reload bottom & echo $! > "/tmp/POLYBAR_BOTTOM_$m"
    echo $index
    index=$(($index+1))
done

