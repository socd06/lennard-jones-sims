#!/bin/bash

main() {
	echo "Sourcing available version of GROMACS..."
	if source /opt/gromacs/gromacs-2020.3-GPU/bin/GMXRC
	then
			echo "Exported GPU-enabled GROMACS 2020.3"
	elif source /opt/gromacs/gromacs-2019.6-GPU/bin/GMXRC
	then
			echo "Exported GPU-enabled GROMACS 2019-6"
	elif source /usr/local/gromacs/bin/GMXRC
	then
			echo "Exported GROMACS"
  elif source /usr/local/gromacs5-1-5/bin/GMXRC
  then
      echo "Exported GROMACS 5.1.5"
	else source /usr/local/gromacs2016-3/bin/GMXRC
			echo "Exported GROMACS 2016-3"
	fi
		run-folders
}

run-folders() {
	for preffix in {3..3}
	do
	  folder=$preffix*
	  echo "going into" $folder
	  cd $folder
		echo "currently in"
		pwd
			for p in {80..100}
			do
				for t in {200..800..6}
				do
					python ../scripts/check_files.py
					if grep -Fxq "$preffix-p$p-t$t" ../iters.txt
						then
						    # code if found
						    echo "Simulation found in log. Skipping..."
							else
							    # code if not found$preffix-p$p-t$t
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
											run-commands > ../logs/sim-$preffix-p$p-t$t.log
											echo "current folder is"
											pwd
										else
											echo "Folder exists... Skipping to radial distribution function"
										fi
											gas-gas > ../logs/rdf-$preffix-p$p-t$t.log 2>&1 &
							fi
					done
				done
				cd ..
		done
	}

	submit(){
		branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
		echo $preffix-p$p-t$t >>../iters-$branch.txt
		echo "Working in $branch branch"
		git add ../iters-$branch.txt
		git add ../results/rdf-$preffix-p$p-t$t.xvg
		git add ../logs/rdf-$preffix-p$p-t$t.log
		git add ../logs/sim-$preffix-p$p-t$t.log
		git commit -m "feat: add $preffix-p$p-t$t radial distribution function and updates to logs"
		# update branch to master
		git pull upstream master
		git push -u origin $branch
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
		gmx rdf -f $FILE.trr -s $FILE.tpr -n indexrdf.ndx -bin 0.001 -rmax 2.0 -o ../results/rdf-$preffix-p$p-t$t.xvg < input
		rm indexrdf.ndx
		rm *.ndx.*
		rm *.mdp.*
		rm -r OUT/p$p-t$t
		submit
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
