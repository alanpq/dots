#!/bin/bash
kill `pgrep -f "python3 ~/scripts/spotify_notifications.py"`
~/scripts/spotify_notifications.py &
