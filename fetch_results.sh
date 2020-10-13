#!/bin/bash

set pass "FIrO/fZ3]"
#PULL FILES FROM MDSIM (results)
scp -P 30 -r test@148.247.198.140:~/lennard-jones-sims/results ~/git/lennard-jones-sims/
send $pass

# PULL FILES FROM DIVDEB (results)
scp -P 26 -r test@148.247.198.140:~/lennard-jones-sims/results ~/git/lennard-jones-sims/
send $pass
