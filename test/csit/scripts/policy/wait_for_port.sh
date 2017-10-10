#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Usage: wait-for-port hostname port" >&2
	exit 1
fi

host=$1
port=$2

echo "Waiting for $host port $port open"
until telnet $host $port </dev/null 2>/dev/null | grep -q '^Connected'; do
	sleep 1
done

echo "$host port $port is open"

exit 0
