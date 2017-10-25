#!/bin/bash
# ex) ./speech2lmfb.sh sample.[wav|wv1|flac|mp3|wma] ./save_directory

export train_cmd=run.pl
export KALDI_ROOT=`pwd`/../../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not
 present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C


if [ ! -f $1 ];then
  echo "input audio $1 is not found"
  exit
fi

audioinput=$1
ffmpeg -i $audioinput &> audio.info
if grep -q "not found" audio.info; then
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

"""
  exit
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
  if grep "wma" <<< $fmt; then
    audioinput=$1.wav
    ffmpeg -i $1 -ar 16000 -ac 1 $audioinput &> audio.log
    echo "converted to $audioinput"
  elif [ $ch -ne 1 ];then
    echo "audio channel needs to be 1"
    exit
  elif [ $sr -ne 16000 ];then
    echo "sampling rate needs to be 16000"
    exit
  fi
fi
rm -f audio.log audio.info

DATA=$2 #where to store kaldi data
UTT_ID=$(echo ${audioinput%.*} | sed 's/.*\///')
mkdir -p $DATA/$UTT_ID
TYPE=${audioinput##*.}

SPH=$KALDI_ROOT/tools/sph2pipe_v2.5/sph2pipe
WSJ=$KALDI_ROOT/egs/wsj/s5

check_flac () {
  check=$(flac --help)
  if [[ $check =~ "flac" ]]; then
    echo "flac command is available"
  else
    echo "flac not found. please install it"
    exit 1
  fi
}

mp3towav () {
  check=$(lame --help)
  if [[ $check =~ "lame" ]]; then
    echo "lame command is available and convert "$1" to "$2
    lame --decode $1 $2
  else
    echo "lame not found. please install it"
    exit 1
  fi
}

WAVSCP=$DATA/$UTT_ID/wav.scp
UTT2SPK=$DATA/$UTT_ID/utt2spk
SPK2UTT=$DATA/$UTT_ID/spk2utt
if [ "$TYPE" == "wav" ];then
  echo $UTT_ID" "$audioinput > $WAVSCP
elif [ "$TYPE" == "wv1" ];then
  echo $UTT_ID" "$SPH" -f wav "$audioinput" |" > $WAVSCP
elif [ "$TYPE" == "flac" ];then
  check_flac
  echo $UTT_ID" flac -c -d -s "$audioinput" |" > $WAVSCP
elif [ "$TYPE" == "mp3" ];then
  mp3towav $audioinput ${audioinput/.mp3/.wav}
  echo $UTT_ID" "${audioinput/.mp3/.wav} > $WAVSCP
fi
echo $UTT_ID" 0001" > $UTT2SPK
echo "0001 "$UTT_ID > $SPK2UTT

KDATA=$DATA/$UTT_ID
LDATA=$DATA/$UTT_ID/log
FDATA=$DATA/$UTT_ID/fbank
$WSJ/steps/make_fbank.sh --cmd "$train_cmd" --nj 1 $KDATA $LDATA $FDATA || exit 1;
$WSJ/utils/fix_data_dir.sh $KDATA || exit;
$WSJ/steps/compute_cmvn_stats.sh $KDATA $LDATA $FDATA || exit 1;

norm_vars=true
add_deltas=true

feats_tr="ark,s,cs:apply-cmvn --norm-vars=$norm_vars --utt2spk=ark:$KDATA/utt2spk \
          scp:$KDATA/cmvn.scp scp:$KDATA/feats.scp ark:- |"
tmpdir=$(mktemp -d /tmp/XXX);
copy-feats "$feats_tr" ark,scp:$tmpdir/tmp.ark,$LDATA/tmp"_"norm.scp || exit 1;
copy-feats scp:$LDATA/tmp"_"norm.scp ark,t:- > $FDATA"_"fbank40.txt
if $add_deltas; then
  copy-feats scp:$LDATA/tmp"_"norm.scp ark,t:- | add-deltas ark,t:- ark,t:- > $FDATA"_"fbank120.txt
fi

rm -rf $tmpdir
rm -f $LDATA/tmp"_"norm.scp

ls $PWD/$FDATA"_"fbank40.txt
ls $PWD/$FDATA"_"fbank120.txt
