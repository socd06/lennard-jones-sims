#!/bin/bash
t=200
p=1

# Always replace last line with temperature
echo -e '$d\nw\nq'| ed 0_md.mdp
echo -e '$d\nw\nq'| ed 0_md.mdp

# Write reference temperature
echo "ref_t = $t" >> 0_md.mdp

# Write reference pressure
echo "ref_p = $p" >> 0_md.mdp

# Delete last line
#sed '$d' 0_md.mdp


#_md.mdp
#_npt.mdp
#_nvt.mdp


