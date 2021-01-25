#!/bin/bash

cd results/1-ne

#history_folder = "/../../history/$f.txt"

for f in *.xvg
do
  echo "Writing History of $f"

  # any way works
  echo "${f::-4}"
  #echo ${f::-4}

  git log --follow -p -- $f > ../../history/${f::-4}.txt

done
