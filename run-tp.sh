#!/bin/bash

# This script is going to modify the Xe concentrations by adding more water to the system

main() {
# Gromacs VERSION
	#source /usr/local/gromacs5-1-5/bin/GMXRC
	#source /usr/local/gromacs2016-3/bin/GMXRC
	source /usr/local/gromacs/bin/GMXRC

# DATA NEEDED:
	# Interval concentration for the different folders, start and end concentration
	export INTERVAL_CONC=1
	#export START_CONC=$INTERVAL_CONC
	export START_CONC=1
	export END_CONC=4


	run-folders
}


run-folders() {
	for (( START_CONC; START_CONC<=END_CONC; START_CONC = START_CONC + INTERVAL_CONC))
	do
		cd $START_CONC-*
		run-commands
		#pwd
		cd ..
	done
}

run-commands() {
	x = 123
gmx grompp -f MDP/0_minim.mdp -c OUT/solv2.gro -p FF/topol.top -o OUT/0-em.tpr
gmx mdrun -v -deffnm OUT/0-em
gmx grompp -f MDP/0_nvt.mdp -c OUT/0-em.gro -p FF/topol.top -o OUT/1-nvt.tpr
gmx mdrun -v -deffnm OUT/1-nvt
gmx grompp -f MDP/0_npt.mdp -c OUT/1-nvt.gro -p FF/topol.top -o OUT/2-npt.tpr
gmx mdrun -v -deffnm OUT/2-npt
gmx grompp -f MDP/0_md.mdp -c OUT/2-npt.gro -p FF/topol.top -o OUT/3-md.tpr -maxwarn 1
gmx mdrun -v -deffnm OUT/3-md
}

main "$@"; exit
