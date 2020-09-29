for filename in 0_md.mdp 0_nvt.mdp; do     
       prefix="${filename%_md.mdp}"
       echo "$suffix md"
done
