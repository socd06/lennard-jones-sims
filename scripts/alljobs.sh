#!/bin/bash

for preffix in {1..4}
do
  folder=$preffix*
  echo "going into" $folder
  cd ../$folder
  echo "currently in"
  pwd
    for p in {1..100}
    do
      for t in {200..800..6}
      do
        echo "$preffix-p$p-t$t" >> ../alliters.txt
      done
    done
  done
