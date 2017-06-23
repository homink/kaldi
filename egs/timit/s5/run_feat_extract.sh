#!/bin/bash

# This script is to build source and target data for use in OpenNMT
# The base came from https://github.com/srvk/eesen/blob/master/asr_egs/wsj/run_ctc_phn.sh
#

onmt=./onmt
mkdir -p $onmt/data

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
set -e

feats_nj=4

echo ============================================================================
echo "                Data & Lexicon & Language Preparation                     "
echo ============================================================================

local/timit_data_prep_txt.sh $timit || exit 1

echo ============================================================================
echo "         MFCC Feature Extration & CMVN for Training and Test set          "
echo ============================================================================

min_len=0
norm_vars=true
add_deltas=true

# Now make 39-dim MFCC features.

echo '''
--htk-compat=true
--window-type=hamming
--num-mel-bins=23
''' > conf/fbank.conf

mfccdir=mfcc
mfcc_txt_dir=onmt/mfcc_txt
mkdir -p $mfcc_txt_dir

for x in train dev test; do 
  steps/make_mfcc.sh --cmd "$train_cmd" --nj $feats_nj data/$x exp/make_mfcc/$x $mfccdir
  steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir

  # sorting by frame length
  feat-to-len scp:data/$x/feats.scp ark,t:- | awk '{print $2}' > $mfcc_txt_dir/len.tmp || exit 1;
  paste -d " " data/$x/feats.scp $mfcc_txt_dir/len.tmp | sort -k3 -n - | awk -v m=$min_len '{ if ($3 >= m) {print $1 " " $2} }' > $mfcc_txt_dir/$x.scp || exit 1;
  rm -f $mfcc_txt_dir/len.tmp

  # save features to a local dir
  feats_tr="ark,s,cs:apply-cmvn --norm-vars=$norm_vars --utt2spk=ark:data/$x/utt2spk scp:data/$x/cmvn.scp scp:$mfcc_txt_dir/$x.scp ark:- |"
  tmpdir=$(mktemp -d $feats_tmpdir);
  copy-feats "$feats_tr" ark,scp:$tmpdir/$x.ark,$mfcc_txt_dir/$x"_"local.scp || exit 1;
  copy-feats scp:$mfcc_txt_dir/$x"_"local.scp ark,t:- | add-deltas ark,t:- ark,t:- > $onmt/data/$x.mfcc39

done


# Now make 40-dim and 120-dim log Mel filter bank features.
echo '''
--num-mel-bins=40
''' > conf/fbank.conf

fbankdir=fbank
fbank_txt_dir=onmt/fbank_txt
mkdir -p $fbank_txt_dir

for set in train dev test; do
  steps/make_fbank.sh --cmd "$train_cmd" --nj $feats_nj data/$set exp/make_fbank/$set $fbankdir || exit 1;
  utils/fix_data_dir.sh data/$set || exit;
  steps/compute_cmvn_stats.sh data/$set exp/make_fbank/$set $fbankdir || exit 1;

  # sorting by frame length
  feat-to-len scp:data/$set/feats.scp ark,t:- | awk '{print $2}' > $fbank_txt_dir/len.tmp || exit 1;
  paste -d " " data/$set/feats.scp $fbank_txt_dir/len.tmp | sort -k3 -n - | awk -v m=$min_len '{ if ($3 >= m) {print $1 " " $2} }' > $fbank_txt_dir/$set.scp || exit 1;
  rm -f $fbank_txt_dir/len.tmp

  # save features to a local dir
  feats_tr="ark,s,cs:apply-cmvn --norm-vars=$norm_vars --utt2spk=ark:data/$set/utt2spk scp:data/$set/cmvn.scp scp:$fbank_txt_dir/$set.scp ark:- |"
  tmpdir=$(mktemp -d $feats_tmpdir);
  copy-feats "$feats_tr" ark,scp:$tmpdir/$set.ark,$fbank_txt_dir/$set"_"local.scp || exit 1;
  copy-feats scp:$fbank_txt_dir/$set"_"local.scp ark,t:- > $onmt/data/$set.fbank40
  if $add_deltas; then
    copy-feats scp:$fbank_txt_dir/$set"_"local.scp ark,t:- | add-deltas ark,t:- ark,t:- > $onmt/data/$set.fbank120
  fi
done
