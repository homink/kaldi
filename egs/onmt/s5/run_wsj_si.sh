#!/bin/bash
#This script doesn't consier speaker dependency and processes 120-dim log mel filter bank feature per single utterance.
#It may affect the performance in the generic Kaldi recipe but could be useful for other application such as end-to-end.

. ./cmd.sh
. ./path.sh

wsj0=/DATA/speech-data/LDC93S6B
wsj1=/DATA/speech-data/LDC94S13B

function check_line () {
  nl=`cat $1 | wc -l`
  [ "$nl" -eq "$2" ] || echo "Warning: expected $2 lines in train_si284.flist, got $nl"
}

function feature_process () {
  cat $1 | while read ln;do
    ./speech2lmfbs.sh $ln $2
  done
}

function merge_process () {
  cat $1 | sed 's/.*\///' | sed 's/\..*//' > $1.uid
  python -c \
'
import sys
fn_out=sys.argv[1];fn_out=fn_out.replace(".flist.uid","_single_fbank"+sys.argv[3]+".txt")
fout=open(fn_out,"w")
fin=open(sys.argv[1])
for line in fin:
  line=line.rstrip();line=line.replace("corpus_","")
  fin2=open(sys.argv[2]+"/"+line+"/fbank_fbank"+sys.argv[3]+".txt")
  mat=fin2.read();fin2.close()
  fout.write("corpus_"+mat)
' "$1.uid" $2 $3
  rm -f $1.uid
}

FDIM=120

if [ ! -f train_si284.flist ];then
  cat $wsj1/13-34.1/wsj1/doc/indices/si_tr_s.ndx \
    $wsj0/11-13.1/wsj0/doc/indices/train/tr_s_wv1.ndx | \
    local/ndx2flist.pl $wsj0/??-{?,??}.? $wsj1/??-{?,??}.? | \
    grep -v -i 11-2.1/wsj0/si_tr_s/401 | sed 's/^/corpus/g' | sort | sed 's/^corpus//g' > train_si284.flist
  
  check_line train_si284.flist 37416
fi

feature_process train_si284.flist train_si284_si
merge_process train_si284.flist train_si284_si $FDIM

if [ ! -f test_eval92.flist ];then 
  cat $wsj0/11-13.1/wsj0/doc/indices/test/nvp/si_et_20.ndx | \
    local/ndx2flist.pl $wsj0/??-{?,??}.? $wsj1/??-{?,??}.? | \
    awk '{printf("%s.wv1\n", $1)}' | sed 's/^/corpus/g' | sort | sed 's/^corpus//g' > test_eval92.flist

  check_line test_eval92.flist 333
fi
feature_process test_eval92.flist test_eval92_si
merge_process test_eval92.flist test_eval92_si $FDIM

rm -f train_si284.flist test_eval92.flist
