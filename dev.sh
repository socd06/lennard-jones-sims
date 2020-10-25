#!/bin/bash

export BEGMD=3000
export ENDMD=6000

main() {
	if source /usr/local/gromacs2016-3/bin/GMXRC
	then
			echo "Exported GROMACS 2016"
	else
			source /usr/local/gromacs/bin/GMXRC
			echo "Exported GROMACS 2020"
	fi
		run-folders
}

run-folders() {
	for preffix in {2..2}
	do
	  folder=$preffix*
	  echo "going into" $folder
	  cd $folder
		echo "currently in"
		pwd
		for p in {1..100}
		do
			for t in {200..800..6}
			do
				if python ../scripts/check_files.py
				then
					echo "Python3 File check succesfull"
				else
					echo "Python3 File check failed. Running Python2 version."
					python ../scripts/check_p2.py
				fi
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
									else
										echo "Folder exists... Skipping to radial distribution function"
									fi
										gas-gas
										# send to main network computer
										scp -P 28 -r -C /home/test/lennard-jones-sims/results/rdf-$preffix-p$p-t$t.xvg test@148.247.198.140:/home/test/git/lennard-jones-sims/results
										stash
						fi
				done
			done
			cd ..
	done
}

stash(){
	# finally update with remote files
	git add /home/test/lennard-jones-sims/results/
	git stash
	git pull
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
