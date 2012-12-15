#!/bin/sh

cores=`sysctl -n hw.ncpu`
i=0

while [ $i -lt $cores  ]
do
	echo Core \#$i: `sysctl -n dev.cpu.$i.temperature`
	i=`expr $i + 1`
done

