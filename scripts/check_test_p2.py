#!/usr/bin/env python
# coding: utf-8

# python 2 version of check_files.py
import os

with open("../testiters.txt","w+") as f:
    for root, dirs, files in os.walk("../test"):
        for name in files:
            print(name[4:-4])
            f.write(name[4:-4])
            f.write("\n")
