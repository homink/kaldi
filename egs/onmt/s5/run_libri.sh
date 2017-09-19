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

write_table () {
  file_table=${1/.flac.lst/.table}
  file_table_tmp=${1/.flac.lst/.table.tmp}
  #[ -e $file_table ] && rm -f $file_table
  if [ -f $file_table ];then
    echo "$file_table found"
    return 1
  fi
  #[ -e $file_table ] && return 1

  cat $1 | while read wavfile; do
    var=$(sed -e 's:.*/\(.*\)/\(.*\)/\(.*\).flac$:\1 \2 \3:i' <<< $wavfile)
    IFS=' ' read spk chapter uttid <<< $var
    trans_fname=$(grep $spk"-"$chapter $2)
    text=$(grep $uttid $trans_fname)
    text=$(sed -e 's/^[0-9\-]* //g' <<< $text)
    text=$(sed -e 's/["&*?()<>:;,{}!/~`]//g' <<< $text)
    gender=$(grep -w "^$spk" $libri/SPEAKERS.TXT | awk '{print $3}')
    echo $spk$'\t'$gender$'\t'$uttid$'\t'$wavfile$'\t'$text >> $file_table_tmp
  done

  sed 's/^/S/g' $file_table_tmp | sort -k 1,1 | sed 's/^S//g' > $file_table
  rm -f $1 $2 $file_table_tmp

}

libri_set=1

[ -e libri_flac.flist ] && rm -f libri_flac.flist
[ -e libri_trans.flist ] && rm -f libri_trans.flist
if [ "$libri_set" -eq 1 ];then
  for dir in dev-clean test-clean train-clean-100;do
    find $libri/$dir -name "*.flac" | sort -V > libri.$dir.flac.lst
    find $libri/$dir -name "*.trans.txt" | sort -V > libri.$dir.trans.lst
    write_table libri.$dir.flac.lst libri.$dir.trans.lst
  done
elif [ "$libri_set" -eq 2 ];then
  for dir in dev-clean test-clean train-clean-100 train-clean-360 $libri/train-other-500;do
    find $libri/$dir -name "*.flac" | sort -V > libri.$dir.flac.lst
    find $libri/$dir -name "*.trans.txt" | sort -V > libri.$dir.trans.lst
    write_table libri.$dir.flac.lst libri.$dir.trans.lst
  done
else
  for dir in dev-clean dev-other test-clean test-other train-clean-100 train-clean-360 $libri/train-other-500;do
    find $libri/$dir -name "*.flac" | sort -V > libri.$dir.flac.lst
    find $libri/$dir -name "*.trans.txt" | sort -V > libri.$dir.trans.lst
    write_table libri.$dir.flac.lst libri.$dir.trans.lst
  done
fi

echo "
  LibriSpeech corpus table is created
"

if [ "$libri_set" -eq 1 ];then
  for x in dev-clean test-clean train-clean-100;do
    echo "Building $x data ..."
    local/extract_feat2lmfb.sh libri.$x.table data/libri_$x data/libri_$x"_"fbank 20
    local/extract_trans.sh data/libri_$x data/libri_$x"_"fbank
  done
elif [ "$libri_set" -eq 2 ];then
  for x in dev-clean test-clean train-clean-100 train-clean-360 train-other-500;do
    echo "Building $x data ..."
    local/extract_feat2lmfb.sh libri.$x.table data/libri_$x data/libri_$x"_"fbank 20
    local/extract_trans.sh data/libri_$x data/libri_$x"_"fbank
  done
else
  for x in dev-clean dev-other test-clean test-other train-clean-100 train-clean-360 train-other-500;do
    echo "Building $x data ..."
    local/extract_feat2lmfb.sh libri.$x.table data/libri_$x data/libri_$x"_"fbank 20
    local/extract_trans.sh data/libri_$x data/libri_$x"_"fbank
  done
fi

echo "
  LibriSpeech corpus feature extraction is done
"

if [ "$libri_set" -eq 1 ];then
  for x in dev-clean test-clean train-clean-100;do
    echo -n "libri_$x""_fbank_fbank120.txt - max of feature frame length: "
    grep -nr "\[" data/libri_$x"_"fbank_fbank120.txt | sed 's/:.*//g' > train_start.txt
    grep -nr "\]" data/libri_$x"_"fbank_fbank120.txt | sed 's/:.*//g' > train_end.txt
    python local/diff.py train_start.txt train_end.txt | sort -V | tail -n 1
    rm -f train_start.txt train_end.txt
    echo -n "libri_$x""_fbank_trans.txt - max of transcription sequence length: "
    cat data/libri_$x"_"fbank_trans.txt | while read line;do echo $line | awk '{$1=""; print$0}' | wc -m; done | sort -V | tail -n 1
  done
fi

#libri_dev-clean_fbank_fbank120.txt - max of feature frame length: 3263
#libri_dev-clean_fbank_trans.txt - max of transcription sequence length: 1033
#libri_test-clean_fbank_fbank120.txt - max of feature frame length: 3494
#libri_test-clean_fbank_trans.txt - max of transcription sequence length: 1153
#libri_train-clean-100_fbank_fbank120.txt - max of feature frame length: 2451
#libri_train-clean-100_fbank_trans.txt - max of transcription sequence length: 797

