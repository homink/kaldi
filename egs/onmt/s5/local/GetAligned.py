#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys

print(sys.argv[1])
print(sys.argv[2])
with open(sys.argv[2]) as f2:
  trans_id = f2.read().splitlines()

fout_name=sys.argv[1]
print(fout_name.replace('.txt','_sub.txt'))
fout=open(fout_name.replace('.txt','_sub.txt'),'w')
id_count=0
stag='  ['
matched=0
with open(sys.argv[1]) as f1:
  for line in f1:
    line = line.rstrip()
    if matched:
      if ']' in line:
        fout.write(line+'\n')
        matched=0
      else:
        fout.write(line+' \n')
    if not matched:
      if stag in line:
        id_count=id_count+1
        if line.replace('  [','') in trans_id:
          matched=1
          fout.write(line+'\n')
fout.close()
