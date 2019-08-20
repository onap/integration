#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "$0 <output.xml> <job> <build>"
    exit 1
fi
ROBOT_OUTPUT=$1
JOB=$2
BUILD=$3

INFLUX_ENDPOINT='http://10.145.123.16:8086/write?db=robot'

TMP_XML=/tmp/output-$JOB-$BUILD.xml

if [ ! -f $TMP_XML ]; then
    xmlstarlet ed -d '//kw' -d '//timeout' -d '//tags' $ROBOT_OUTPUT | tr -d '\n' > $TMP_XML

    # Canonicalize Robot suite names
    sed -i 's/ONAP.Verify/ONAP_CI/g' $TMP_XML
    sed -i 's/ONAP.Daily/ONAP_CI/g' $TMP_XML
    sed -i 's/OpenECOMP.ETE/ONAP_CI/g' $TMP_XML
fi


TIMESTR=$(xmlstarlet sel -t -v "/robot/@generated" $TMP_XML)
TIME=$(date -d "${TIMESTR}Z" +%s%N)

POINTS_FILE=/tmp/points-$JOB-$BUILD.txt
rm -f $POINTS_FILE

# test
xmlstarlet sel -t -m "//test" -c "." -n $TMP_XML | while read test; do
    NAME=$(echo "$test" | xmlstarlet sel -t -v "/test/@name" | tr ' ' '_' | xmlstarlet unesc)
    if [ "PASS" = $(echo "$test" | xmlstarlet sel -t -v "/test/status/@status" ) ]; then
        PASS=1
        FAIL=0
    else
        PASS=0
        FAIL=1
    fi
    STARTTIME=$(date -d "$(echo $test | xmlstarlet sel -t -v "/test/status/@starttime")Z" +%s%N)
    ENDTIME=$(date -d "$(echo $test | xmlstarlet sel -t -v "/test/status/@endtime")Z" +%s%N)
    echo test,job=$JOB,name=$NAME build=$BUILD,pass=$PASS,fail=$FAIL,starttime=$STARTTIME,endtime=$ENDTIME $TIME | tee -a $POINTS_FILE
done

# suite
xmlstarlet sel -t -m "/robot/statistics/suite/stat" -c "." -n $TMP_XML | while read suite; do
    ID=$(echo "$suite" | xmlstarlet sel -t -v "/stat/@id" )
    STATUS=$(xmlstarlet sel -t -m "//suite[@id=\"$ID\"]/status" -c "." -n $TMP_XML)
    STARTTIMESTR=$(echo $STATUS | xmlstarlet sel -t -v "/status/@starttime")
    ENDTIMESTR=$(echo $STATUS | xmlstarlet sel -t -v "/status/@endtime")
    NAME=$(echo "$suite" | xmlstarlet sel -t -m "/stat" -v . | tr ' ' '_' | xmlstarlet unesc)
    PASS=$(echo "$suite" | xmlstarlet sel -t -v "/stat/@pass" )
    FAIL=$(echo "$suite" | xmlstarlet sel -t -v "/stat/@fail" )
    if [ "$STARTTIMESTR" != "N/A" ] && [ "$ENDTIMESTR" != "N/A" ]; then
	STARTTIME=$(date -d "${STARTTIMESTR}Z" +%s%N)
	ENDTIME=$(date -d "${ENDTIMESTR}Z" +%s%N)
	echo suite,job=$JOB,name=$NAME build=$BUILD,pass=$PASS,fail=$FAIL,starttime=$STARTTIME,endtime=$ENDTIME $TIME | tee -a $POINTS_FILE
    else
	echo suite,job=$JOB,name=$NAME build=$BUILD,pass=$PASS,fail=$FAIL $TIME | tee -a $POINTS_FILE
    fi
done

# tag
xmlstarlet sel -t -m "/robot/statistics/tag/stat" -c "." -n $TMP_XML | while read tag; do
    NAME=$(echo "$tag" | xmlstarlet sel -t -m "/stat" -v . | tr ' ' '_' | xmlstarlet unesc)
    PASS=$(echo "$tag" | xmlstarlet sel -t -v "/stat/@pass" )
    FAIL=$(echo "$tag" | xmlstarlet sel -t -v "/stat/@fail" )
    echo tag,job=$JOB,name=$NAME build=$BUILD,pass=$PASS,fail=$FAIL $TIME | tee -a $POINTS_FILE
done

curl -i $INFLUX_ENDPOINT --data-binary @$POINTS_FILE
