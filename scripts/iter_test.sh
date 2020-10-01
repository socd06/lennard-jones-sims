#!/bin/bash
t=200
p=1

# Always replace last line with temperature
#echo -e '$d\nw\nq'| ed 0_md.mdp
#echo -e '$d\nw\nq'| ed 0_md.mdp

# increase temperature in +6 intervals
for p in {1..3}
do
	for t in {200..212..6}
	do
		mkdir p$p-t$t
		cd p$p-t$t
	# Write reference temperature
	echo "ref_t = $t" >> test.mdp

	# Write reference pressure
	echo "ref_p = $p" >> test.mdp

	echo "ref_p = $p / ref_t = $t" >> current_params.txt

	cd ..

	done

done

# Write reference pressure
#echo "ref_p = $p" # >> 0_md.mdp

# Delete last line
#sed '$d' 0_md.mdp


#_md.mdp
#_npt.mdp
#_nvt.mdp
