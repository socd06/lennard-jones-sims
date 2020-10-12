#!/bin/bash

# xtc file with simulation data

export BEGMD=3000
export ENDMD=6000

main() {
	# Source all GROMACS VERSIONs installed
	#source /usr/local/gromacs5-1-5/bin/GMXRC
	source /usr/local/gromacs/bin/GMXRC
	source /usr/local/gromacs2016-3/bin/GMXRC
	source /usr/local/gromacs/bin/GMXRC

	run-folders
}

run-folders() {
	for preffix in {1..4}
	do
	  folder=$preffix*
	  echo "going into" $folder
	  cd $folder
		echo "currently in"
		pwd
			# All iterations
			#for p in {1..100}
			# Just 2 iterations
			for p in {1..1}
			do
				# All iterations
				#for t in {200..800..6}
				# Just 2 iterations
				for t in {200..200..6}
				do
					# UNCOMMENT WHEN DONE WITH TESTING
					mkdir OUT/p$p-t$t
					export FILE="OUT/p$p-t$t/3-md"
					# Modify 0_md file
					# remove last two lines from 0_md file
					echo -e '$d\nw\nq'| ed MDP/0_md.mdp
					echo -e '$d\nw\nq'| ed MDP/0_md.mdp

					# write pressure and temperature iterations
					echo "ref_p 		=" $p>>MDP/0_md.mdp
					echo "ref_t 		=" $t>>MDP/0_md.mdp

					# Modify 0_npt file
					# remove last two lines from 0_npt file
					echo -e '$d\nw\nq'| ed MDP/0_npt.mdp
					echo -e '$d\nw\nq'| ed MDP/0_npt.mdp

					# write pressure and temperature iterations
					echo "ref_p 		=" $p>>MDP/0_npt.mdp
					echo "ref_t 		=" $t>>MDP/0_npt.mdp

					# Modify 0_nvt file
					# remove last lines from 0_nvt file
					echo -e '$d\nw\nq'| ed MDP/0_nvt.mdp

					# write temperature iterations
					echo "ref_t 		=" $t>>MDP/0_nvt.mdp

					# UNCOMMENT AFTER TESTS
					run-commands

					gas-gas
					cd OUT/p$p-t$t
					rm 0-* 1-* 2-* 3-*
				done
			done
			cd ..
	done
}

gas-gas(){
	echo "del 0-4" > input
	echo " " >> input
	echo "q" >> input
	gmx make_ndx -f $FILE.tpr -o indexrdf.ndx < input

	echo "0" > input
	echo "0" >> input
	gmx rdf -f $FILE.trr -s $FILE.tpr -n indexrdf.ndx -bin 0.001 -rmax 3.9  -b $BEGMD -e $ENDMD -o rdf-$preffix-p$p-t$t.xvg < input
	rm input indexrdf.ndx
}


run-commands() {
	gmx grompp -f MDP/0_minim.mdp -c OUT/solv2.gro -p FF/topol.top -o OUT/p$p-t$t/0-em.tpr
	gmx mdrun -v -deffnm OUT/p$p-t$t/0-em
	echo "saving to" OUT/p$p-t$t-0-em
	gmx grompp -f MDP/0_nvt.mdp -c OUT/0-em.gro -p FF/topol.top -o OUT/p$p-t$t/1-nvt.tpr
	gmx mdrun -v -deffnm OUT/p$p-t$t/1-nvt
	echo "saving to" OUT/p$p-t$t/1-nvt
	gmx grompp -f MDP/0_npt.mdp -c OUT/1-nvt.gro -p FF/topol.top -o OUT/p$p-t$t/2-npt.tpr
	gmx mdrun -v -deffnm OUT/p$p-t$t/2-npt
	echo "saving to" OUT/p$p-t$t/2-npt
	gmx grompp -f MDP/0_md.mdp -c OUT/2-npt.gro -p FF/topol.top -o OUT/p$p-t$t/3-md.tpr -maxwarn 1
	gmx mdrun -v -deffnm OUT/p$p-t$t/3-md
	echo "saving to" OUT/p$p-t$t-3-md
}

main "$@"; exit
