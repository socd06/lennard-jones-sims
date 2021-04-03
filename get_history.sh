#!/bin/bash

set -e
in="${1:-iters-beo.txt}"

[ ! -f "$in" ] && { echo "$0 - File $in not found."; exit 1; }

while IFS= read -r file
do
  gas=${file:0:1}*
	#echo "Checking results/$gas/rdf-$file.xvg ..."
  # Check if file exists already
  if test -f history/rdf-$file.txt
    then
      echo "history/rdf-$file.txt already generated. Skipping... "
    else
      echo "Getting commit history of results/$gas/rdf-$file.xvg"
      #echo results/$gas
      git log --follow -p -- results/$gas/rdf-$file.xvg > history/rdf-$file.txt

      echo "DONE!"
    fi
      git add history
      git commit -m "add commit history of $file for analysis"
      git push -u origin cd

done < "${in}"
