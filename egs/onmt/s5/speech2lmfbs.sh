#!/bin/bash
#This scrpit processes single utterance and produces 120-dim log mel filter bank feature to desginated directory.
#It supports data augmentation
# ex) ./speech2lmfb.sh sample.[wav|wv1|flac|mp3|wma] ./save_directory

export train_cmd=run.pl
export KALDI_ROOT=`pwd`/../../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not
 present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C

perturbed=0;num_copies=3
fbank_type="fbank40 fbank120"

set -e
. utils/parse_options.sh


check_arg () {
  if [ ! -f $1 ];then
    echo "input audio $1 is not found"
    echo "ex) ./speech2lmfb.sh sample.[wav|wv1|flac|mp3|wma] ./save_directory"
    exit
  elif [ -z "$2" ];then
    echo "directory for processed data is missing"
    echo "ex) ./speech2lmfb.sh sample.[wav|wv1|flac|mp3|wma] ./save_directory"
    exit
  fi
}

help_ffmpeg () {
  echo """
ffmpeg not found. please install it

For CentOS, the following will be helpful.

CentOS 7.x:
sudo rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm

CentOS 6.x:
sudo rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el6/x86_64/nux-dextop-release-0-2.el6.nux.noarch.rpm

sudo yum install ffmpeg ffmpeg-devel -y

For Ubuntu,

sudo apt-get install ffmpeg

"""
  exit

}

audio_conversion () {
  ffmpeg -i $1 -ar 16000 -ac 1 $2 &> audio.log
  echo "converted to $2"
  rm -f audio.log
}

check_arg $1 $2

ffprobe -i $1 &> audio.info

if grep -q "not found" audio.info; then
  help_ffmepg

else
  info3=$(python -c \
'
#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys,re
info=sys.argv[1]
info=info.replace(",","")
info=filter(None,info.split(" "))
type=info[info.index("Audio:")+1]
if type=="none":
  type=info[0].replace("[","")

sr=info[info.index("Hz")-1]
if "mono" in info:
  ch="1"
else:
  ch=info[info.index("channels")-1]

print(sr+" "+ch+" "+type)
' "$(grep "Audio:" audio.info)")
  sr=$(echo $info3 | cut -f1 -d" ")
  ch=$(echo $info3 | cut -f2 -d" ")
  fmt=$(echo $info3 | cut -f3 -d" ")
  echo "your audio file is sampled at $sr Hz with $ch channels(s) in a format of $fmt"

  file_converted=0
  if grep "nistsphere" <<< $fmt; then
    echo "nistsphere format is going to be handled in kaldi"
    audioinput=$1
  elif grep "pcm_s16le" <<< $fmt; then
    echo "wav format is going to be handled in kaldi"
    audioinput=$1
  elif grep "wma" <<< $fmt;then
    audioinput=${1/.wma/.wav}
    audio_conversion $1 $audioinput
    file_converted=1
  elif grep "mp3" <<< $fmt;then
    audioinput=${1/.mp3/.wav}
    audio_conversion $1 $audioinput
    file_converted=1
  elif grep "flac" <<< $fmt;then
    audioinput=${1/.flac/.wav}
    audio_conversion $1 $audioinput
    file_converted=1
  elif [ $sr -ne 16000 ];then
    echo "sampling rate needs to be 16000"
    exit
  fi
fi

rm -f audio.info

DATA=$2 #where to store kaldi data
UTT_ID=$(echo ${audioinput%.*} | sed 's/.*\///')
mkdir -p $DATA/$UTT_ID
TYPE=${audioinput##*.}

SPH=$KALDI_ROOT/tools/sph2pipe_v2.5/sph2pipe
WSJ=$KALDI_ROOT/egs/wsj/s5

WAVSCP=$DATA/$UTT_ID/wav.scp
UTT2SPK=$DATA/$UTT_ID/utt2spk
SPK2UTT=$DATA/$UTT_ID/spk2utt
if [ "$TYPE" == "wav" ];then
  echo $UTT_ID" "$audioinput > $WAVSCP
elif [ "$TYPE" == "wv1" ];then
  echo $UTT_ID" "$SPH" -f wav "$audioinput" |" > $WAVSCP
fi
echo $UTT_ID" 0001" > $UTT2SPK
echo "0001 "$UTT_ID > $SPK2UTT

KDATA=$DATA/$UTT_ID
LDATA=$KDATA/log
FDATA=$KDATA/data
nj=1

$WSJ/steps/make_fbank.sh --cmd "$train_cmd" --nj $nj $KDATA $LDATA $FDATA || exit 1;
$WSJ/utils/fix_data_dir.sh $KDATA || exit;
$WSJ/steps/compute_cmvn_stats.sh $KDATA $LDATA $FDATA || exit 1;

# Speech data augmenation using VTLN warp factor and time-warp factor
if [ "$perturbed" -eq 1 ]; then
  echo ">>> perturbed is set and in progress..."
  PDATA=$KDATA"_"aug
  steps/nnet2/get_perturbed_feats.sh --nj $nj --num_copies $num_copies \
    conf/fbank.conf $PDATA"_"fbank $LDATA"_"aug $KDATA $PDATA
  KDATA=$PDATA
  LDATA=$PDATA
  echo ">>> The perturbed process is done"
fi

function check_uid {

  ! grep "\[" $1 | sed 's/  \[//g' | \
  cmp -s - <(awk '{print $1}' $2) \
  && echo "uid between feature and transcription not matched"
  echo "$1 and $2 well matched!"
}

norm_vars=true
add_deltas=true

feats_tr="ark,s,cs:apply-cmvn --norm-vars=$norm_vars --utt2spk=ark:$KDATA/utt2spk \
          scp:$KDATA/cmvn.scp scp:$KDATA/feats.scp ark:- |"
copy-feats "$feats_tr" ark,scp:$LDATA/tmp.ark,$LDATA/tmp"_"norm.scp || exit 1;

#Copying to 40 & 120 dimenstional filter bank coefficients with text format
for fbank in $fbank_type;do
  echo ">>> $fbank is in progress ..."
  if [ "$fbank" == "fbank40" ];then
    copy-feats scp:$LDATA/tmp"_"norm.scp ark,t:- > $KDATA"_"$fbank.txt
    echo ">>> Checking utternce IDs between feature and transcription ..."
    check_uid $KDATA"_"$fbank.txt $KDATA/text
  elif [ "$fbank" == "fbank120" ];then
    copy-feats scp:$LDATA/tmp"_"norm.scp ark,t:- | add-deltas ark,t:- ark,t:- > $KDATA"_"$fbank.txt
    echo ">>> Checking utternce IDs between feature and transcription ..."
    check_uid $KDATA"_"$fbank.txt $KDATA/text
  fi
  ls $KDATA"_"$fbank.txt
done

rm -f $LDATA/tmp"_"norm.scp $LDATA/tmp.ark

if [ "$file_converted" -eq 1 ];then
  rm -f $audioinput
fi
