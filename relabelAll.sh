#!/bin/bash

for file in run_*/aa-PofZ.txt
do
	echo $file
	dir=$(dirname "$file")
	./relabelPofZ.pl -m "simSampleList.map.txt" -n "ThreeGensGtypFreq.txt" -p $file -o "${dir}/aa-PofZ.relabeled.txt"
done

exit
