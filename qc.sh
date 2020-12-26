#!/bin/bash

# read qc-test file
cat qc-test.txt | while read file || [[ -n $file ]];
do

  echo "Checking $file"
  preffix=${file:4:1}
  #cd results/$preffix*
  pwd

  # grep to see which lines have git commit comments
  # for example : grep -n '>>>>>>>' results/1-ne/rdf-1-p95-t716.xvg

  #echo "FULL MATCH"
  #grep -n ">>>>>" results/$preffix*/$file
  #echo "MATCH WITHOUT FULL LINE"
  #grep -n ">>>>>" results/$preffix*/$file | cut -d : -f 1

  # Count how many matches there are
  pattern="<<<<<<<|>>>>>>>|======"
  # git commit comments always start with one of the three above

  matches=$(grep -E -n $pattern results/$preffix*/$file | cut -d : -f 1 | wc -l)
  echo "Found $matches matches"

  grep -E -n $pattern results/$preffix*/$file | cut -d : -f 1 | tail -$matches
  # make an array an put lines matched there
  declare -a match_arr=()

  #get line from grep
  line=$(grep -E -n $pattern  results/$preffix*/$file | cut -d : -f 1 | tail -$matches)
  #echo "#$i Match line $line"
  #match_arr+=($line)
  match_arr+=($line)
  echo "Matches array: ${match_arr[*]}, TOTAL=${#match_arr[@]}"
  #remove git comments using sed $lined $file
  echo "lenght is ${#match_arr[@]}"

  command=""

  for ((i=0; i<$matches; i++))
  do
    echo Iteration $i ${match_arr[i]}
    command+=${match_arr[i]}"d;"

  done

  echo $command
  # remove using single sed command but with all error lines
  # add -i when finished testing
  sed -i $command results/$preffix*/$file
  #echo "Removed line!"

done
