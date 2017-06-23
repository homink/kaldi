#!/bin/bash
# This script is to build target by searching utterance key of feature from corpus

infile=$(sed -e 's:.[a-z0-9]*$::i' <<< $1)

[ -e $infile.tgt ] && rm -f $infile.tgt
grep "\[" $1 | sed 's/ \[//g' > $infile.key
cat $infile.key | while read LINE
do
  s1=$(echo $LINE | cut -f1 -d"_")
  s2=$(echo $LINE | cut -f2 -d"_")
  phn_file="$timit/*/*/"$s1"/"$s2".phn"

  if [ ! -f $phn_file ]
  then
    echo "$phn_file not found"
    exit
  fi
  python onmt/phn2seq.py $phn_file $LINE >> $infile.tgt
done

rm -f $infile.key
