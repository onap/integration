#!/bin/bash
MAIN_DIRECTORY=./files/onap
FILE_TEMPLATE=./templates/file_template.xml.gz
UPDATE_MINS=15
NUM_NODES=20
NUM_FILES=10

rm -rf $MAIN_DIRECTORY/*
for ((m=1;m<=$NUM_NODES;m++))
do
	DIRECTORY=$MAIN_DIRECTORY/"node"$m
	mkdir -p "$DIRECTORY"
done

for ((n=0;n<$NUM_FILES;n++))
do
	if [[ "$OSTYPE" == "linux-gnu" ]]; then		# Linux OS
		DATE=$(date -d $(($UPDATE_MINS*$n))" minutes ago" +"%Y%m%d")
		TIME_START=$(date -d $(($UPDATE_MINS*($n+1)-1))" minutes ago" +"%H%M")
		TIME_END=$(date -d $(($UPDATE_MINS*$n))" minutes ago" +"%H%M")  
	elif [[ "$OSTYPE" == "darwin"* ]]; then		# Mac OS
		DATE=$(date -v "-"$(($UPDATE_MINS*$n))"M" +"%Y%m%d")
		TIME_START=$(date -v "-"$(($UPDATE_MINS*($n+1)-1))"M" +"%H%M")
		TIME_END=$(date -v "-"$(($UPDATE_MINS*$n))"M" +"%H%M")
	else
		echo "ERROR: OS not supported"
		exit 1
	fi

	FILE_NAME_TIMESTAMP="A"$DATE"."$TIME_START"-"$TIME_END
	TIMESTAMP_ARRAY[$n]=$FILE_NAME_TIMESTAMP

	for ((m=1;m<=$NUM_NODES;m++))
	do
		DIRECTORY=$MAIN_DIRECTORY/"node"$m
		FILE_NAME=$FILE_NAME_TIMESTAMP"_node"$m".xml.gz"
		cp $FILE_TEMPLATE $DIRECTORY/$FILE_NAME
	done
done

while true
do
	sleep $(($UPDATE_MINS*60))
	OLD_TIMESTAMP=${TIMESTAMP_ARRAY[$NUM_FILES-1]}
	unset TIMESTAMP_ARRAY[$NUM_FILES-1]

	DATE=$(date +"%Y%m%d")
	TIME_END=$(date +"%H%M")
	if [[ "$OSTYPE" == "linux-gnu" ]]; then		# Linux OS
		TIME_START=$(date -d $(($UPDATE_MINS-1))" minutes ago" +"%H%M")
	elif [[ "$OSTYPE" == "darwin"* ]]; then		# Mac OS
		TIME_START=$(date -v "-"$(($UPDATE_MINS-1))"M" +"%H%M")
	else
		echo "ERROR: OS not supported"
		exit 1
	fi

	NEW_TIMESTAMP="A"$DATE"."$TIME_START"-"$TIME_END
	TIMESTAMP_ARRAY=("$NEW_TIMESTAMP" "${TIMESTAMP_ARRAY[@]}")

	for ((m=1;m<=$NUM_NODES;m++))
	do
		DIRECTORY=$MAIN_DIRECTORY/"node"$m
		OLD_FILE_NAME=$OLD_TIMESTAMP"_node"$m".xml.gz"
		NEW_FILE_NAME=$NEW_TIMESTAMP"_node"$m".xml.gz"
		mv $DIRECTORY/$OLD_FILE_NAME $DIRECTORY/$NEW_FILE_NAME
		echo "Renamed OLD file: "$OLD_FILE_NAME" to NEW file: "$NEW_FILE_NAME
	done
done
