#!/bin/bash

URL="$1"
PARAMS="$2"
MAX_RUNS="$3"

SUM_TIME="0"
MAXTIME="0"
MAXTIME_ARR=(0)

if [ -z $URL ] || [ -z $PARAMS ] || [ -z $MAX_RUNS ]; then
    echo "Invalid arguments."
    exit 1
fi

i="0"
while [ $i -lt $MAX_RUNS ]; do
    TIME=`curl $URL -d $PARAMS -o /dev/null -s -w %{time_total}`
    echo "Executing http request, timing: ${TIME}/${MAXTIME}"
    if [ $(awk 'BEGIN{ print ('$MAXTIME' < '$TIME') }') -eq 1 ]; then
        MAXTIME=$TIME
    fi
    MAXTIME_ARR+=($TIME)
    TIME="${TIME/,/.}"
    SUM_TIME=`echo "scale=5; $TIME + $SUM_TIME" | bc`
    i=$[$i+1]
done

TIME_AVERAGE=`echo "scale=5; $SUM_TIME / $MAX_RUNS" | bc`
echo "Sum: $SUM_TIME"
echo "Avg: $TIME_AVERAGE"
echo "Max: $MAXTIME"
#echo "Max arr: ${MAXTIME_ARR[@]}"
for i in "${MAXTIME_ARR[@]}"; do
    percent=$(awk "BEGIN { pc=100*${i}/${MAXTIME}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
    if [ $(awk 'BEGIN{print (50 <= '$percent')}') -eq 1 ]; then
        echo "${percent}% $MAXTIME/$i"
    fi
done
