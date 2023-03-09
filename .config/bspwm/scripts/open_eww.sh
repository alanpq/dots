mons=$(xrandr --listactivemonitors | tail -n +2 | cut -d':' -f1)

eww close-all

for m in $mons; do
  echo $m
  eww open --screen $m eww-bar-top-$m
  eww open --screen $m eww-bar-bottom-$m
done

