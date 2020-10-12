
p=1
t=200
echo p$p-t$t
if grep -Fxq p$p-t$t iters.txt
then
    # code if found
    echo "Simulation found in log. Skipping..."
else
    # code if not found
    echo "Not found. Simulating..."
fi
