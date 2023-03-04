#!/bin/bash

# TODO: use bspc query to fetch monitor list
# FIXME: actually support multi monitor stuff

declare -A bars
bars[0]="top"
bars[1]="bottom"

declare -A monitors
monitors[0x00400006]="eDP-1"

declare -A bar_idxs
counter=0
for i in "${!monitors[@]}"; do
  bar_idxs[$monitors[$i]}]=""
  #bar_idxs[${monitors[$i]}]="$counter"
  ((counter=counter+1))
done

echo ${bars[@]}
echo ${monitors[@]}
echo ${bar_idxs[@]}

bspc subscribe node_state | while read -r _ mon _ _ state flag; do
  if [[ "$state" != fullscreen ]]; then continue; fi
  for bar in "${bars[@]}"; do 
    if [[ "$flag" == on ]]; then
      echo "mon: $mon"
      echo "$bar${bar_idxs[${monitors[$mon]}]}"
      xdotool search --class "$bar${bar_idxs[${monitors[$mon]}]}" windowunmap
    else
      xdotool search --class "$bar${bar_idxs[${monitors[$mon]}]}" windowmap
    fi
  done
done

