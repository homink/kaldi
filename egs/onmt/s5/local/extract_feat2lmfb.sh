
# ex) ./extract_feat2text.sh [options] wsj.table data/wsj exp/make_fbank/wsj perturbed
# --perturbed [true|flase]
# --nj 5

perturbed=0
nj=3
num_copies=3
fbank_type="fbank40 fbank120"

set -e
. utils/parse_options.sh 

TABLE=$1
KDATA=$2
FDATA=$3
echo "TABLE: $TABLE, KDATA: $KDATA, FDATA: $FDATA"

mkdir -p $KDATA
mkdir -p $FDATA

LDATA=exp/log

TAB=$'\t'
sph2pipe=$KALDI_ROOT/tools/sph2pipe_v2.5/sph2pipe

[ -e $KDATA/spk2gender ] && rm -f $KDATA/spk2gender
[ -e $KDATA/utt2spk ] && rm -f $KDATA/utt2spk
[ -e $KDATA/spk2utt ] && rm -f $KDATA/spk2utt
[ -e $KDATA/text ] && rm -f $KDATA/text
[ -e $KDATA/wav.scp ] && rm -f $KDATA/wav.scp

# KALDI data preparation http://kaldi-asr.org/doc/data_prep.html
awk '{printf("corpus_%s %s\n",$1,tolower($2))}' $TABLE | uniq > $KDATA/spk2gender
awk '{printf("corpus_%s corpus_%s\n",$3,$1)}' $TABLE > $KDATA/utt2spk
cat $KDATA/utt2spk | utils/utt2spk_to_spk2utt.pl > $KDATA/spk2utt
awk -F'\t' '{printf("corpus_%s %s\n",$3,$5)}' $TABLE > $KDATA/text
tmp_line=$(awk '{print $4}' $TABLE | head -n 1)
if grep -q ".wav" <<< $tmp_line;then
  awk '{printf("corpus_%s %s\n",$3,$4)}' $TABLE > $KDATA/wav.scp
elif grep -q ".flac" <<< $tmp_line;then
  awk '{printf("corpus_%s flac -c -d -s %s |\n",$3,$4)}' $TABLE > $KDATA/wav.scp
else
  awk '{printf("corpus_%s '$sph2pipe' -f wav %s |\n",$3,$4)}' $TABLE > $KDATA/wav.scp
fi

# Mel filter bank computation
steps/make_fbank.sh --cmd "$train_cmd" --nj $nj $KDATA $LDATA $KDATA"_"fbank || exit 1;
utils/fix_data_dir.sh $KDATA || exit;
steps/compute_cmvn_stats.sh $KDATA $LDATA $KDATA"_"fbank || exit 1;

echo ">>> Mel filter bank computation done!"

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

#Storing the normalized Mel filter bank data
feats_tr="ark,s,cs:apply-cmvn --norm-vars=true --utt2spk=ark:$KDATA/utt2spk \
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
done

rm -f $LDATA/tmp"_"norm.scp $LDATA/tmp.ark

echo "Converting transcription to be used for OpenNMT ..."
awk '{print $1}' $KDATA/text > temp.uid

if [ "$(head -n 1 $KDATA/text | grep -o '_' | wc -l)" -gt 3 ]; then
  echo "Already formatted"
  awk '{$1=""}1' $KDATA/text | sed 's/^ //g' > temp.trans
else
  awk '{$1=""}1' $KDATA/text | sed 's/^ //g;s/ /_/g;s/./& /g;s/\(.*\)/\L\1/g' > temp.trans
fi
paste -d' ' temp.uid temp.trans > $KDATA"_"trans.txt
rm -f temp.uid temp.trans

