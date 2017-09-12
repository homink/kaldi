#!/bin/bash

# This script proudces feature vectors and transcription for used in OpenNMT


. ./cmd.sh
. ./path.sh

echo """
Reading WSJ corpus (LDC93S6B, LDC94S13B) in Progress ...
"""

wsj0=/media/kwon/DISK2/DEV/DATA/LDC93S6B
wsj1=/media/kwon/DISK2/DEV/DATA/LDC94S13B

if [ ! -f wsj.table ]; then

  if [ ! -f $wsj0/wsj0-train-spkrinfo.txt ]; then
    wget https://catalog.ldc.upenn.edu/docs/LDC93S6A/wsj0-train-spkrinfo.txt -P $wsj0
  fi
  spkrinfo="$wsj0/11-13.1/wsj0/doc/spkrinfo.txt $wsj1/13-32.1/wsj1/doc/evl_spok/spkrinfo.txt  $wsj1/13-34.1/wsj1/doc/dev_spok/spkrinfo.txt $wsj1/13-34.1/wsj1/doc/train/spkrinfo.txt $wsj0/wsj0-train-spkrinfo.txt"

  missing_spk=$(grep "01l" $wsj0/wsj0-train-spkrinfo.txt)
  if [ -z "$missing_spk" ];then
    echo "01l   M    ?                 ?" >> $wsj0/wsj0-train-spkrinfo.txt
  fi

  cat $wsj1/13-34.1/wsj1/doc/indices/si_tr_s.ndx \
    $wsj0/11-13.1/wsj0/doc/indices/train/tr_s_wv1.ndx | \
    local/ndx2flist.pl $wsj0/??-{?,??}.? $wsj1/??-{?,??}.? | \
    grep -v -i 11-2.1/wsj0/si_tr_s/401 > train_si284.flist

  nl=`cat train_si284.flist | wc -l`
  [ "$nl" -eq 37416 ] || echo "Warning: expected 37416 lines in train_si284.flist, got $nl"

  cat $wsj0/11-13.1/wsj0/doc/indices/test/nvp/si_et_20.ndx | \
    local/ndx2flist.pl $wsj0/??-{?,??}.? $wsj1/??-{?,??}.? | \
    awk '{printf("%s.wv1\n", $1)}' > test_eval92.flist

  cat $wsj1/13-32.1/wsj1/doc/indices/wsj1/eval/h1_p0.ndx | \
    sed s/13_32_1/13_33_1/ | \
    local/ndx2flist.pl $wsj0/??-{?,??}.? $wsj1/??-{?,??}.? > test_eval93.flist

  cat $wsj1/13-34.1/wsj1/doc/indices/h1_p0.ndx | \
    local/ndx2flist.pl $wsj0/??-{?,??}.? $wsj1/??-{?,??}.? > test_dev93.flist

  [ -e dot_files.flist ] && rm -f dot_files.flist
  for x in $wsj0/??-{?,??}.? $wsj1/??-{?,??}.?;do
    find -L $x -iname '*.dot';
  done > dot_files.flist

  [ -e tmp.table ] && rm -f tmp.table
  noiseword="<NOISE>";
  cat train_si284.flist test_eval92.flist test_eval93.flist test_dev93.flist > audio.flist
  cat audio.flist | sort | while read wavfile; do
    var=$(sed -e 's:.*/\(.*\)/\(.*\).wv1$:\1 \2:i' <<< $wavfile)
    IFS=' ' read spk uttid <<< $var
    dotid=${uttid:0:6}
    dot=$(grep $dotid dot_files.flist)
    text=$(echo $uttid" " $(grep $uttid $dot | sed -e 's/*//g') | local/normalize_transcript.pl $noiseword)
    text=${text/$uttid" "/}
    text=${text/" ("$(echo $uttid | awk '{print toupper($0)}')")"/}
    text=$(echo $text | sed -e 's/["&*?():;,{}!/~`]//g')
    gender=$(grep -w "^$spk" $spkrinfo | awk '{print $2}')
    echo $spk$'\t'$gender$'\t'$uttid$'\t'$wavfile$'\t'$text >> tmp.table
  done

  sed 's/^/corpus/g' tmp.table | sort -k 1,1 | sed 's/^corpus//g' > wsj.table
  rm -f audio.flist dot_files.flist tmp.table

  echo "
    WSJ corpus table is created
  "
else
  echo "
    WSJ corpus table is already made
  "
fi

build_all=0;only_trans=1
echo """--num-mel-bins=40
--sample-frequency=16000""" > conf/fbank.conf

if [ $build_all -eq 1 ]; then
  echo "Building all data ..."
  local/extract_feat2lmfb.sh wsj.table data/wsj data/wsj_fbank

else
  if [ ! -f wsj_dev.table ]; then
    for uid in `sed -e 's:.*/\(.*\).wv1$:\1:i' test_eval92.flist | head -n 33`;do
      grep $uid wsj.table
    done > wsj_tmp.table
    sed 's/^/corpus/g' wsj_tmp.table | sort -k 1,1 | sed 's/^corpus//g' > wsj_dev.table
  else
    echo "wsj_dev.table found"
  fi

  if [ ! -f wsj_test.table ]; then
    for uid in `sed -e 's:.*/\(.*\).wv1$:\1:i' test_eval92.flist`;do
      grep $uid wsj.table
    done > wsj_tmp.table
    sed 's/^/corpus/g' wsj_tmp.table | sort -k 1,1 | sed 's/^corpus//g' > wsj_test.table
  else
    echo "wsj_test.table"
  fi

  if [ ! -f wsj_train.table ]; then
    for uid in `sed -e 's:.*/\(.*\).wv1$:\1:i' train_si284.flist`;do
      grep $uid wsj.table
    done > wsj_tmp.table
    sed 's/^/corpus/g' wsj_tmp.table | sort -k 1,1 | sed 's/^corpus//g' > wsj_train.table
  fi


  for x in dev test train;do
    echo "Building $x data ..."
    if [ "$only_trans" -eq 1 ]; then
      echo "Building $x transcription data only ..."
      local/extract_trans.sh data/wsj_$x data/wsj_$x"_"fbank
    else
      local/extract_feat2lmfb.sh wsj_$x.table data/wsj_$x data/wsj_$x"_"fbank
      local/extract_trans.sh data/wsj_$x data/wsj_$x"_"fbank
    fi
  done
fi

for fn in data/wsj_dev_fbank_trans.txt data/wsj_test_fbank_trans.txt data/wsj_train_fbank_trans.txt
do
  cat $fn |  sed -e 's/ < n o i s e > _/ <n> _/g' | sed -e 's/ _ < n o i s e >/ _ <n>/g' \
    > ${fn/.txt/_nm.txt}
done

echo -n "wsj_train_fbank_fbank120.txt - max of feature frame length: "
grep -nr "\[" data/wsj_train_fbank_fbank120.txt | sed 's/:.*//g' > train_start.txt
grep -nr "\]" data/wsj_train_fbank_fbank120.txt | sed 's/:.*//g' > train_end.txt
python diff.py train_start.txt train_end.txt | sort -V | tail -n 1
rm -f train_start.txt train_end.txt
echo -n "wsj_train_fbank_fbank120.txt - max of transcription sequence length: "
cat data/wsj_dev_fbank_trans.txt | while read line;do echo $line | awk '{$1=""; print$0}' | wc -m; done | sort -V | tail -n 1
