#!/bin/bash

# TODO: use bspc query to fetch monitor list
# FIXME: actually support multi monitor stuff

declare -A bars
bars[0]="eww-bar-top"
bars[1]="eww-bar-bottom"

declare -A monitors
monitors[0x00400006]="eDP-1"

declare -A bar_idxs
counter=0
for i in "${!monitors[@]}"; do
  bar_idxs[${monitors[$i]}}]=""
  #bar_idxs[${monitors[$i]}]="$counter"
  ((counter=counter+1))
done

echo bars: ${bars[@]}
echo monitors: ${monitors[@]}
echo bar_idxs: ${bar_idxs[@]}

bspc subscribe node_state desktop_focus | while read -r _ mon _ _ state flag; do
  if [[ "$state" != fullscreen ]]; then continue; fi
  echo "===== fullscreen change ===="
  for bar in "${bars[@]}"; do 
    echo "BAR '$bar'"
    if [[ "$flag" == on ]]; then
      echo "  mon: $mon"
      echo "  bar: $bar${bar_idxs[${monitors[$mon]}]}"
      xdotool search --class $bar windowunmap
      #xdotool search --class "$bar${bar_idxs[${monitors[$mon]}]}" windowunmap
    else
      echo "  mon: $mon"
      echo "  bar: $bar${bar_idxs[${monitors[$mon]}]}"
      xdotool search --class $bar windowmap
      #xdotool search --class "$bar${bar_idxs[${monitors[$mon]}]}" windowmap
    fi
  done
done

