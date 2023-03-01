OUT=$(ping 8.8.4.4 -c 1 -W 1 | sed -rn 's/.*time=(.*).*/\1/p')
if [ "$OUT" = "" ];
then
    echo "cringe"
else
    echo $OUT
fi
