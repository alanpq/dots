#!/usr/bin/env bash
/usr/bin/env autorandr left-vertical

systemctl restart --user picom &
systemctl restart --user polybar &

/usr/bin/env wal --theme random &
/usr/bin/env nitrogen --restore &
