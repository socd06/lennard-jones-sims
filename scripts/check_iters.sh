
preffix=1
p=1
t=200
echo "$preffix-p$p-t$t"
if grep -Fxq 1-p$p-t$t iters.txt
then
    # code if found
    echo "Simulation found in log. Skipping..."
else
    # code if not found
    echo "Not found. Simulating..."
    echo "testing more"
fi
echo "some other stuff"
