if [ -z "$1" ]; then
	echo ""
else
	ip -4 -o addr show dev $1 | grep -Po '[\d\.]*' | grep -m 1 '\.' | tee /tmp/ipaddr
fi
