
# ex) ./extract_feat2text.sh wsj.table data/wsj exp/make_fbank/wsj


echo "
  KALDI data preparation...
"
TABLE=$1
KDATA=$2
FDATA=$3
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

GetCPU () {
  if [ -z "$1" ]; then NUM_CPU=4; else NUM_CPU=$1; fi
}

GetCPU $4
steps/make_fbank.sh --cmd "$train_cmd" --nj $NUM_CPU $KDATA $LDATA $FDATA || exit 1;
utils/fix_data_dir.sh $KDATA || exit;
steps/compute_cmvn_stats.sh $KDATA $LDATA $FDATA || exit 1;

echo "Feature precessing done!"

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

echo "Feature text extraction done!"

echo "Checking utternce IDs between feature and transcription ..."

function check_uid {
  ! grep "\[" $1 | sed 's/  \[//g' | \
  cmp -s - <(awk '{print $1}' $2) \
  && echo "uid between feature and transcription not matched"
}

check_uid $FDATA"_"fbank40.txt $KDATA/text
if $add_deltas; then
  check_uid $FDATA"_"fbank120.txt $KDATA/text
fi
