#!/bin/bash
kill `pgrep -f "python3 /home/gamer/scripts/spotify_notifications.py"`
~/scripts/spotify_notifications.py &
