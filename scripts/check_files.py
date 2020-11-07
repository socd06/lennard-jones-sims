#!/usr/bin/env python
# coding: utf-8

# In[71]:

import os
filename = "../iters.txt"
#filename = "../jobs.txt"
pvar = "Python3 scan... "
with open(filename,"w+") as f:
    try:
        entries = os.scandir('../results/')
        for entry in entries:
            #print(entry.name[4:-4])
            f.write(entry.name[4:-4])
            f.write("\n")

        print(pvar+"Success!")
    except:
        print(pvar+"Failed!")
        try:
            pvar = "Python2 scan..."

            for root, dirs, files in os.walk("../results"):
                for name in files:
                    #print(name[4:-4])
                    f.write(name[4:-4])
                    f.write("\n")

            print(pvar+"Success!")
        except:
            print(pvar+"Failed!")
