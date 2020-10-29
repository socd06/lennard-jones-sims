#!/bin/bash

upload(){
  touch test.file
  echo "add results folders and iters.txt"
  git add results/
  git add iters.txt
  echo "commit"
  git commit -m "feat: automatic adding of latest results"
  echo "push to repo"
  git push origin master
}

main(){

  upload
}

main "$@"; exit
