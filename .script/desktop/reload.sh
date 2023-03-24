CHOICE=$(echo $'sxhkd\nbspc\neww\npolybar\nspotifyd\ndunst\nalbert' | dmenu -i)


case "$CHOICE" in
	"")
		echo "Selection cancelled. Aborting.."
		exit
	;;
  "bspc")
    exec $HOME/.config/bspwm/bspc &
  ;;
	"polybar")
		killall polybar
		rm /tmp/POLYBAR_*
		exec $HOME/.script/launch_polybar.sh &>/tmp/polybar.log &
	;;
  "eww")
    exec $HOME/.config/bspwm/scripts/open_eww.sh &
  ;;
	"spotifyd")
		systemctl --user restart spotifyd
	;;
	*)
		killall "$CHOICE" >/dev/null
		exec $($CHOICE) &
	;;
esac
echo "Restarting '$CHOICE'..."
