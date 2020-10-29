#!/bin/bash

# This script is going to calculate the Deuterium order parameter for different lipids
main() {
	#source /usr/local/gromacs2016-3/bin/GMXRC
	#source /usr/local/gromacs5-1-5/bin/GMXRC
	source /opt/gromacs/gromacs-2019.6-GPU/bin/GMXRC

    # Name of the filenames to analyze
	export TYPE=(1-ne 2-ar 3-kr 4-xe)				# Name of the filename

	export FILE="./OUT/3-md"		# Name of the xtc file which has all the data
	# Inicio, fin, en ps
#	export BEGMD=8000
#	export ENDMD=10000
	export BEGMD=3000
	export ENDMD=6000

	#gas-gas
for i in "${TYPE[@]}"
do
	cd $i
	gas-gas
	rm *.ndx
	#pwd
	#tail -1 $FILE.gro
	mv *.xvg ../
	cd ../
done
}
gas-gas(){
echo "del 0-1" > input
echo " " >> input
echo "q" >> input
gmx make_ndx -f $FILE.tpr -o indexrdf.ndx < input

echo "0" > input
echo "0" >> input
gmx rdf -f $FILE.trr -s $FILE.tpr -n indexrdf.ndx -bin 0.001 -rmax 3.9  -b $BEGMD -e $ENDMD -o rdf-$i.xvg < input
rm input indexrdf.ndx
}

main "$@"; exit
