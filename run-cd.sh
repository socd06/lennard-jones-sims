#!/bin/bash

# xtc file with simulation data

export BEGMD=3000
export ENDMD=6000

main() {
	# Source all GROMACS VERSIONs installed
	#source /usr/local/gromacs5-1-5/bin/GMXRC
	source /usr/local/gromacs2016-3/bin/GMXRC
	source /usr/local/gromacs/bin/GMXRC

	if python scripts/check_files.py
	then
		echo "Python3 File check succesfull"
		run-folders
	else
		echo "Python3 File check failed. Running Python2 version."
		python scripts/check_p2.py
		run-folders
	fi
}

run-folders() {
	# One iteration
	#for preffix in {1..1}
	# All iterations
	for preffix in {1..4}
	do
	  folder=$preffix*
	  echo "going into" $folder
	  cd $folder
		echo "currently in"
		pwd
			# Just 1 iterations
			# divdeb running p=1
			# mdsim running p=2
			# crls running p=3
			#for p in {1..100}
			# All iterations
			for p in {1..100}
			do
				# All iterations
				#for t in {200..800..6}
				# Just 5 iterations
				#for t in {200..800..6}
				for t in {200..800..6}
				do
					if grep -Fxq "$preffix-p$p-t$t" ../iters.txt
					then
					    # code if found
					    echo "Simulation found in log. Skipping..."
						else
						    # code if not found
						    echo "Not found. Simulating..."

								# UNCOMMENT WHEN DONE WITH TESTING
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

								# make temporary folder to store simulated variables
								if mkdir OUT/p$p-t$t
									then
										echo "Making folder"
										# UNCOMMENT AFTER TESTS
										run-commands
										echo "current folder is"
										pwd
										gas-gas
										cleanup
									else
										echo "Folder exists... Skipping to radial distribution function"
										gas-gas
										cleanup
									fi
							fi
					done
				done
				cd ..
		done
	}

	cleanup(){
		# remove duplicate mdout files
		rm *mdout.mdp*
		# write pressure and temperature in iteration log
		echo $preffix-p$p-t$t >> ../iters.txt
		rm -r OUT/p$p-t$t
	}

	gas-gas(){
		echo "del 0-1" > input
		echo " " >> input
		echo "q" >> input
		echo "Generating index groups"
		gmx make_ndx -f $FILE.tpr -o indexrdf.ndx < input

		echo "0" > input
		echo "0" >> input
		echo "calculating radial distribution function"
		gmx rdf -f $FILE.trr -s $FILE.tpr -n indexrdf.ndx -bin 0.001 -rmax 3.9  -b $BEGMD -e $ENDMD -o ../results/rdf-$preffix-p$p-t$t.xvg < input
		rm indexrdf.ndx
	}


	run-commands() {
		gmx grompp -f MDP/0_minim.mdp -c OUT/solv2.gro -p FF/topol.top -o OUT/p$p-t$t/0-em.tpr
		gmx mdrun -v -deffnm OUT/p$p-t$t/0-em
		echo "saving to" OUT/p$p-t$t/0-em
		gmx grompp -f MDP/0_nvt.mdp -c OUT/p$p-t$t/0-em.gro -p FF/topol.top -o OUT/p$p-t$t/1-nvt.tpr
		gmx mdrun -v -deffnm OUT/p$p-t$t/1-nvt
		echo "saving to" OUT/p$p-t$t/1-nvt
		gmx grompp -f MDP/0_npt.mdp -c OUT/p$p-t$t/1-nvt.gro -p FF/topol.top -o OUT/p$p-t$t/2-npt.tpr
		gmx mdrun -v -deffnm OUT/p$p-t$t/2-npt
		echo "saving to" OUT/p$p-t$t/2-npt
		gmx grompp -f MDP/0_md.mdp -c OUT/p$p-t$t/2-npt.gro -p FF/topol.top -o OUT/p$p-t$t/3-md.tpr -maxwarn 1
		gmx mdrun -v -deffnm OUT/p$p-t$t/3-md
		echo "saving to" OUT/p$p-t$t/3-md
	}

	main "$@"; exit
