CHOICE=$(echo $'sxhkd\npolybar\ndunst' | dmenu -i)


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
	*)
		killall "$CHOICE" >/dev/null
		exec $($CHOICE) &
	;;
esac
echo "Restarting '$CHOICE'..."
