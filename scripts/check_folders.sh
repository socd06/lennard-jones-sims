#!/bin/bash

for preffix in {1..4}
do
  folder=$preffix*
  echo "going into" $folder
  cd $folder
  cd ..
done
