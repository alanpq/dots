#!/bin/sh

# Replace if already running
running=$(pidof -x $0)
if [ "$(echo $running | wc -w)" -gt "1" ]; then
	echo "Already running..."
	exit 1
fi
#while [ "$(echo $running | wc -w)" -gt "1" ]; do
	
#	oldprocess=$(echo $running| rev| cut -d' ' -f1| rev)
	
#	kill $oldprocess
#	sleep 1
	
#	running=$(pidof -x $0)
#done

DIR="/tmp/spot_dunst"
mkdir -p $DIR
META="$DIR/metadata"

echo "Getting metadata..."
playerctl -p spotifyd metadata --format "{{ artist }}\n{{ title }}\n{{mpris:artUrl}}"|xargs -0I{} printf "{}" > $META
echo "Parsing metadata..."
artist=$(sed '1q;d' $META | sed -e "s/[,[(]....*[])]*//g"| sed "s/ *$//"| sed "s/^\(.\{28\}[^ ]*\)\(.*\)$/\1[\2]/"| sed "s/\[ *\]$//"| sed "s/\[.*\]$/.../")
title=$(sed '2q;d' $META | sed -e "s/[-,[(]....*[])]*//g"| sed "s/ *$//"| sed "s/^\(.\{20\}[^ ]*\)\(.*\)$/\1[\2]/"| sed "s/\[ *\]$//"| sed "s/\[.*\]$/.../" )
echo $(cat $META)

url=$(sed '3q;d' $META | sed "s/open\.spotify\.com/i.scdn.co/")
id=$(echo $url | sed "s/https:\/\/i\.scdn\.co\/image\///")

FILE="$DIR/$id.jpeg"
ERROR_FILE="$HOME/.config/dunst/scripts/error.png"
echo "Fetching thumbnail..."
if [ ! -f "$FILE" ]; then
  if curl "$url" -m 1 > $FILE; then
		echo "Got thumb."
	else
		echo "Could not fetch thumbnail."
		rm $FILE
		FILE=$ERROR_FILE
	fi
else
	echo "Thumbnail cached."
fi
echo $FILE
dunstify -r "991361" -i $FILE "$title" "<span foreground='#1DB954' font_desc='Ubuntu Mono 9'><b>Spotify</b> </span><span font_desc='Ubuntu Mono 4'>\n \n</span><span font_desc='Ubuntu Mono 11'><b>$artist</b></span>"

#rm $temp

