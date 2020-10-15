#!/usr/bin/env python
# coding: utf-8

# In[71]:


import os
entries = os.scandir('results')

with open("iters.txt","w+") as f:
    for entry in entries:
        #print(entry.name[4:-4])
        f.write(entry.name[4:-4])
        f.write("\n")
