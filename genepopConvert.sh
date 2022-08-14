#!/bin/bash

INFILE="output_genepop.gen"
OUTFILE="Cdis_x_Clat.simulated.3gen.newhybrids"

if [ ! -f "${INFILE}.bak"  ]
then
	cp $INFILE "${INFILE}.bak"
else
	cp "${INFILE}.bak" $INFILE
fi

HEADER=`head -1 $INFILE`

sed -i "s/$HEADER/Title:\"\"/g" $INFILE
sed -i 's/-/_/g' $INFILE
sed -i 's/pop/Pop/g' $INFILE
sed -i 's/, / ,  /g' $INFILE

./genepop2newhybrids.pl -m Cdis_x_Clat.map.txt -o $OUTFILE -g $INFILE -z Cdis_ref -Z Clat_ref > "${OUTFILE}.sampleOrder.txt"

sed -i 's/ ,  / /g' $OUTFILE
sed -i 's/NumLoci\t1/NumLoci\t200/g' $OUTFILE

exit
