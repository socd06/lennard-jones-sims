#!/bin/bash

export BEGMD=3000
export ENDMD=6000

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
		#run-folders
    echo "Done."
}

main "$@"; exit
