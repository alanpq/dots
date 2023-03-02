CHOICE=$(echo $'sxhkd\npolybar\nspotifyd\ndunst\nalbert' | dmenu -i)


case "$CHOICE" in
	"")
		echo "Selection cancelled. Aborting.."
		exit
	;;
	"polybar")
		killall polybar
		rm /tmp/POLYBAR_*
		exec $HOME/.script/launch_polybar.sh &>/tmp/polybar.log &
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
