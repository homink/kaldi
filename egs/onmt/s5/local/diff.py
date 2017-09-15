#!/usr/bin/python
# -*- coding: utf-8 -*-

from itertools import izip
import sys

with open(sys.argv[1]) as textfile1, open(sys.argv[2]) as textfile2:
    for x, y in izip(textfile1, textfile2):
        x = x.strip()
        y = y.strip()
        #print("x: " + x + ", y: " + y)
        print("%d" % (int(y)-int(x)))
