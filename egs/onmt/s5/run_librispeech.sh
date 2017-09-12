#!/bin/bash

. ./cmd.sh
. ./path.sh

echo """
Reading LibriSpeech Corpus in Progress ...
"""

libri=/DATA/speech-data/LibriSpeech/LibriSpeech

check=$(flac --help)
if [[ $check =~ "flac" ]]; then
  echo "flac command is available"
else
  echo "flac not found. please install it"
  exit 1
fi

[ -e libri_flac.flist ] && rm -f libri_flac.flist
[ -e libri_flac_sub.flist ] && rm -f libri_flac_sub.flist
#find $libri/test-clean $libri/test-other $libri/train-clean-100 $libri/train-clean-360 $libri/train-other-500 -name "*.flac" | sort > libri_flac.flist
find $libri/train-clean-100 -name "*.flac" | sort > libri_flac.flist
head -n 10000 libri_flac.flist > libri_flac_sub.flist
[ -e libri_trans.flist ] && rm -f libri_trans.flist
#find $libri/test-clean $libri/test-other $libri/train-clean-100 $libri/train-clean-360 $libri/train-other-500 -name "*.trans.txt" | sort > libri_trans.flist
find $libri/train-clean-100 -name "*.trans.txt" | sort > libri_trans.flist

[ -e libri_tmp.table ] && rm -f libri_tmp.table
cat libri_flac_sub.flist | while read wavfile; do
  var=$(sed -e 's:.*/\(.*\)/\(.*\)/\(.*\).flac$:\1 \2 \3:i' <<< $wavfile)
  IFS=' ' read spk chapter uttid <<< $var
  trans_fname=$(grep $spk"-"$chapter libri_trans.flist)
  text=$(grep $uttid $trans_fname)
  text=$(sed -e 's/^[0-9\-]* //g' <<< $text)
  text=$(sed -e 's/["&*?()<>:;,{}!/~`]//g' <<< $text)
  gender=$(grep -w "^$spk" $libri/SPEAKERS.TXT | awk '{print $3}')
  echo $spk$'\t'$gender$'\t'$uttid$'\t'$wavfile$'\t'$text >> libri_tmp.table
done

sed 's/^/S/g' libri_tmp.table | sort -k 1,1 | sed 's/^S//g' > libri.table
rm -f libri_flac.flist libri_trans.flist libri_tmp.table

echo "
  LibriSpeech corpus table is created
"
#for x in test_clean test_other train_clean_100 train_clean_360 train_other_500;do
for x in train_clean_100_sub;do
  echo "Building $x data ..."
  local/extract_feat2lmfb.sh libri.table data/libri_$x data/libri_$x"_"fbank
  local/extract_trans.sh data/libri_$x data/libri_$x"_"fbank
done
