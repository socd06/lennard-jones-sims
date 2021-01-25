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
		read_csv
}

read_csv(){
  INPUT=errores.csv
  OLDIFS=$IFS
  IFS=','

  [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
  #while read Presion Temperatura
  while read p t folder
  do
  	#echo "Pressure : $Presion Temperature : $Temperatura"
    echo "GAS: $folder | Pressure: $p | Temperature: $t"

    # Modify 0_md file
    # remove last two lines from 0_md file
    echo -e '$d\nw\nq'| ed $folder/MDP/0_md.mdp
    echo -e '$d\nw\nq'| ed $folder/MDP/0_md.mdp

    # write pressure and temperature iterations
    echo "ref_p 		=" $p>>$folder/MDP/0_md.mdp
    echo "ref_t 		=" $t>>$folder/MDP/0_md.mdp

    # Modify 0_npt file
    # remove last two lines from 0_npt file
    echo -e '$d\nw\nq'| ed $folder/MDP/0_npt.mdp
    echo -e '$d\nw\nq'| ed $folder/MDP/0_npt.mdp

    # write pressure and temperature iterations
    echo "ref_p 		=" $p>>$folder/MDP/0_npt.mdp
    echo "ref_t 		=" $t>>$folder/MDP/0_npt.mdp

    # Modify 0_nvt file
    # remove last lines from 0_nvt file
    echo -e '$d\nw\nq'| ed $folder/MDP/0_nvt.mdp

    # write temperature iterations
    echo "ref_t 		=" $t>>$folder/MDP/0_nvt.mdp

    export preffix="${folder:0:1}"

		if mkdir $folder/OUT/p$p-t$t
			then
				echo "Making folder"

		    run-commands > logs/sim-$preffix-p$p-t$t.log
		    echo "current folder is"
		    pwd
			else
				echo "Folder exists... Skipping to radial distribution function"
			fi
				FINISHED=results/rdf-$preffix-p$p-t$t.xvg
				if test -f "$FINISHED"
					then
						echo "Simulation already finished. Skipping."
					else
		    		gas-gas > logs/rdf-$preffix-p$p-t$t.log 2>&1 &
					fi
						echo "DONE!"

  done < $INPUT
  IFS=$OLDIFS
}

submit(){
  branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
  echo $preffix-p$p-t$t >>iters-$branch.txt
  echo "Working in $branch branch"
  git add iters-$branch.txt
  git add results/rdf-$preffix-p$p-t$t.xvg
  git add logs/rdf-$preffix-p$p-t$t.log
  git add logs/sim-$preffix-p$p-t$t.log
  git commit -m "feat: add $preffix-p$p-t$t radial distribution function and updates to logs"
  # update branch to master
  git pull upstream master
  git push -u origin $branch
}

gas-gas(){
	echo "currently at:"
	pwd
	export FILE="$folder/OUT/p$p-t$t/3-md"
  echo "del 0-1" > $folder/input
  echo " " >> $folder/input
  echo "q" >> $folder/input
  echo "Generating index groups"
  gmx make_ndx -f $FILE.tpr -o $folder/indexrdf.ndx < $folder/input

  echo "0" > $folder/input
  echo "0" >> $folder/input
  echo "calculating radial distribution function"
  gmx rdf -f $FILE.trr -s $FILE.tpr -n $folder/indexrdf.ndx -bin 0.001 -rmax 2.0 -o results/rdf-$preffix-p$p-t$t.xvg < $folder/input
  rm $folder/indexrdf.ndx
  rm $folder/*.ndx.*
  rm $folder/*.mdp.*
  #rm -r OUT/p$p-t$t
  submit
}


run-commands() {
  gmx grompp -f $folder/MDP/0_minim.mdp -c $folder/OUT/solv2.gro -p $folder/FF/topol.top -o $folder/OUT/p$p-t$t/0-em.tpr
  gmx mdrun -v -deffnm $folder/OUT/p$p-t$t/0-em
  echo "saving to" $folder/OUT/p$p-t$t/0-em
  gmx grompp -f $folder/MDP/0_nvt.mdp -c $folder/OUT/p$p-t$t/0-em.gro -p $folder/FF/topol.top -o $folder/OUT/p$p-t$t/1-nvt.tpr
  gmx mdrun -v -deffnm $folder/OUT/p$p-t$t/1-nvt
  echo "saving to" $folder/OUT/p$p-t$t/1-nvt
  gmx grompp -f $folder/MDP/0_npt.mdp -c $folder/OUT/p$p-t$t/1-nvt.gro -p $folder/FF/topol.top -o $folder/OUT/p$p-t$t/2-npt.tpr
  gmx mdrun -v -deffnm $folder/OUT/p$p-t$t/2-npt
  echo "saving to" $folder/OUT/p$p-t$t/2-npt
  gmx grompp -f $folder/MDP/0_md.mdp -c $folder/OUT/p$p-t$t/2-npt.gro -p $folder/FF/topol.top -o $folder/OUT/p$p-t$t/3-md.tpr -maxwarn 1
  gmx mdrun -v -deffnm $folder/OUT/p$p-t$t/3-md
  echo "saving to" $folder/OUT/p$p-t$t/3-md
}

	main "$@"; exit
