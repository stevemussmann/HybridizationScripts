#!/bin/bash

SPEC="Cdis_x_Clat"
FILE="${SPEC}.simulated.3gen.newhybrids"
GTYPCAT="ThreeGensGtypFreq.txt"
seed1=123
seed2=456

DIR="/home/mussmann/scratch02/dx2003/newhybrids_ref/simulation/3gen/Cdis_x_Clat/01_radiator_genomic_converter_20220807@1821"

COM="commandfile.${SPEC}.txt"
rm $COM

for i in `seq 1 4`
do
	mkdir -p "${DIR}/simulation/run_${i}"
	cp $FILE "${DIR}/simulation/run_${i}/."
	cp $GTYPCAT "${DIR}/simulation/run_${i}/."
	echo "cd ${DIR}/simulation/run_${i}/; newhybrids -c $GTYPCAT -d $FILE --burn-in 100000 --num-sweeps 1000000 -s $seed1 $seed2 --no-gui;" >> $COM
	seed1=$(($seed1+111))
	seed2=$(($seed2+111))

done

cat $COM | parallel

exit
