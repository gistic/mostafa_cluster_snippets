#!/bin/bash

IFS=$'\r\n'

for line in $(hadoop fs -ls /nyc_taxi_spatial); do
	
	PATH=${line#*/}
	FILENAME=${PATH##*/}

	echo $PATH
	echo $FILENAME

	echo "alter table nyc_taxi_trips partition (tag='$FILENAME') set location '/$PATH';"
    
done

/nyc_trips_sample/tag=data_00001_1.rtree
/nyc_trips_sample/tag=data_00001_1.rtree