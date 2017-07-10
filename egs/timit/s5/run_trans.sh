#!/bin/bash

. ./cmd.sh
[ -f path.sh ] && . ./path.sh

echo "looking for $1"
[ -e $1.trans ] && rm -f $1.trans
for x in `awk '{print $1}' $1`; do
  y=$(awk -F'_' '{printf("%s/%s/%s.txt\n",$3,$1,$2)}' <<< $x)
  ss=$(sed -e 's:.*/\(.*\).tgt$:\1:i' <<< $1)
  if [ "$ss" == "dev" ]; then
    y="$timit/test/"$y
  else
    y=$timit/$ss"/"$y
  fi
  if ! [ -e $y ]; then
    echo "$y not found"
    exit 1
  fi
  z=$(cat $y | sed 's/^0 [0-9]* //g' | sed 's/[\;\:\"\!\?\.\,]//g' | \
           sed -e 's/\(.*\)/\L\1/'| sed 's/ /_/g' | sed 's/./& /g')
  echo $x" "$z >> $1.trans
done

