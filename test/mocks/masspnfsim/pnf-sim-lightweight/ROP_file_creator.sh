#!/bin/bash
MAIN_DIRECTORY=${PWD##*/}
FULL_DIRECTORY=${PWD}
FILE_DIRECTORY=$FULL_DIRECTORY/files/onap
FILE_TEMPLATE=$FULL_DIRECTORY/templates/file_template_new.xml.gz
UPDATE_MINS=15
NUM_FILES=96

rm -rf $FILE_DIRECTORY
mkdir -p "$FILE_DIRECTORY"

for ((n=0;n<$NUM_FILES;n++))
do
	if [[ "$OSTYPE" == "linux-gnu" ]]; then		# Linux OS
		DATE=$(date -d $(($UPDATE_MINS*($n+1)-1))" minutes ago" +"%Y%m%d")
		TIME_START=$(date -d $(($UPDATE_MINS*($n+1)-1))" minutes ago" +"%H%M%z")
		TIME_END=$(date -d $(($UPDATE_MINS*$n))" minutes ago" +"%H%M%z")  
	elif [[ "$OSTYPE" == "darwin"* ]]; then		# Mac OS
		DATE=$(date -v "-"$(($UPDATE_MINS*($n+1)-1))"M" +"%Y%m%d")
		TIME_START=$(date -v "-"$(($UPDATE_MINS*($n+1)-1))"M" +"%H%M%z")
		TIME_END=$(date -v "-"$(($UPDATE_MINS*$n))"M" +"%H%M%z")
	else
		echo "ERROR: OS not supported"
		exit 1
	fi

	FILE_NAME_TIMESTAMP="A"$DATE"."$TIME_START"-"$TIME_END
	FILE_NAME=$FILE_NAME_TIMESTAMP"_"$HOSTNAME"-"$MAIN_DIRECTORY".xml.gz"
	cp $FILE_TEMPLATE $FILE_DIRECTORY/$FILE_NAME

	TIMESTAMP_ARRAY[$n]=$FILE_NAME_TIMESTAMP
done

while true
do
	sleep $(($UPDATE_MINS*60))
	OLD_TIMESTAMP=${TIMESTAMP_ARRAY[$NUM_FILES-1]}
	unset TIMESTAMP_ARRAY[$NUM_FILES-1]

	TIME_END=$(date +"%H%M%z")
	if [[ "$OSTYPE" == "linux-gnu" ]]; then		# Linux OS
		DATE=$(date -d $(($UPDATE_MINS-1))" minutes ago" +"%Y%m%d")
		TIME_START=$(date -d $(($UPDATE_MINS-1))" minutes ago" +"%H%M%z")
	elif [[ "$OSTYPE" == "darwin"* ]]; then		# Mac OS
		DATE=$(date -v "-"$(($UPDATE_MINS-1))"M" +"%Y%m%d")
		TIME_START=$(date -v "-"$(($UPDATE_MINS-1))"M" +"%H%M%z")
	else
		echo "ERROR: OS not supported"
		exit 1
	fi

	NEW_TIMESTAMP="A"$DATE"."$TIME_START"-"$TIME_END
	OLD_FILE_NAME=$OLD_TIMESTAMP"_"$HOSTNAME"-"$MAIN_DIRECTORY".xml.gz"
	NEW_FILE_NAME=$NEW_TIMESTAMP"_"$HOSTNAME"-"$MAIN_DIRECTORY".xml.gz"
	mv $FILE_DIRECTORY/$OLD_FILE_NAME $FILE_DIRECTORY/$NEW_FILE_NAME
	#echo "Renamed OLD file: "$OLD_FILE_NAME" to NEW file: "$NEW_FILE_NAME      # uncomment for debugging

	TIMESTAMP_ARRAY=("$NEW_TIMESTAMP" "${TIMESTAMP_ARRAY[@]}")
done
