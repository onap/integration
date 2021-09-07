#!/bin/bash

# Script to print internal dfc stats every 5 sec to screen and file
# Default port is 8100 for DFC
# Useage: ./dfc-internal-stats.sh all|internal|jvm [<dfc-port-number>]

print_usage() {
	echo "Useage: ./dfc-internal-stats.sh all|internal|jvm [<dfc-port-number>]"
}
stat=""
if [ $# -eq 0 ]; then
	dfcport=8100
	stat="all"
elif [ $# -eq 1 ]; then
	dfcport=8100
	stat=$1
elif [ $# -eq 2 ]; then
	dfcport=$2
	stat=$1
else
	print_usage
	exit 1
fi

heading=1

if [ $stat == "all" ]; then
	echo "Printing stats for both JVM and DFC using port "$dfcport
elif [ $stat == "internal" ]; then
	echo "Printing stats for DFC using port "$dfcport
elif [ $stat == "jvm" ]; then
	echo "Printing stats for JVM using port "$dfcport
else
	print_usage
	exit 1
fi
fileoutput=".tmp_stats.txt"

echo "Stats piped to file: "$fileoutput

rm $fileoutput



floatToInt() {
    printf "%.0f\n" "$@"
}

do_curl_actuator() {
    val=$(curl -s localhost:${dfcport}/actuator/metrics/${1} |  grep -o -E "\"value\":[0-9.E]+" | awk -F\: '{print $2}')
    val=$(floatToInt $val)
    printf "%-20s %+15s\n" $1 $val
    if [ $heading -eq 1 ]; then
    	echo -n "," $1 >> $fileoutput
    else
    	echo -n "," $val >> $fileoutput
    fi
}

do_curl_status() {
	    curl -s localhost:${dfcport}/status > ./.tmp_curl_res
	    cat ./.tmp_curl_res
	    while read line; do
	    	len=${#line}
	    	if [ $len -gt 0 ]; then
	    	    val=${line#*:}
    			id=${line%"$val"}
	    		if [ $heading -eq 1 ]; then
    				echo -n "," $id >> $fileoutput
    			else
    				echo -n "," $val >> $fileoutput
    			fi
    		fi
		done < ./.tmp_curl_res

}

OK=0 # Flag for DFC response (0==no response, 1==reponse ok and logging can start)

while [ true ]; do
	if [ $OK -eq 0 ]; then
		test=$(curl -s localhost:${dfcport}/status)
		if [ -z "$test" ] && [ $heading -eq 1 ]; then
			echo "No response from dfc on port: ${dfcport}. Retrying..."
		else
			echo "Response from dfc on port: ${dfcport}. Starts logging."
			OK=1
		fi
	fi
	if [ $OK -eq 1 ]; then
		if [ $heading -eq 1 ]; then
	    	echo  -n "date" >> $fileoutput
	    else
	    	ds=$(date)
	    	echo -n $ds >> $fileoutput
	    fi
	    if [ $stat == "all" ] || [ $stat == "jvm" ]; then
	    	echo "=========    DFC JVM Stats   ========="
	    	do_curl_actuator jvm.threads.live
	    	do_curl_actuator jvm.threads.peak
	    	do_curl_actuator process.files.open
	    	do_curl_actuator process.files.max
	    	do_curl_actuator jvm.memory.used
	    	do_curl_actuator jvm.memory.max
	    fi

		if [ $stat == "all" ] || [ $stat == "internal" ]; then
	    	echo "========= DFC internal Stats ========="
	    	do_curl_status
	    fi
		echo ""  >> $fileoutput
		heading=0
	fi
    sleep 5
done
