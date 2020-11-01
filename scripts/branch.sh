#!/bin/bash

# read current branch
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

echo "In $branch branch"
