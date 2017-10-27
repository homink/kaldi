. cmd.sh
. path.sh
set -e # exit on error

use_dev=false # Use the first 4k sentences from training data as dev set. (39 speakers.)

#CSJDATATOP=/db/laputa1/data/processed/public/CSJ ## CSJ database top directory.
CSJDATATOP=/BIG_DATA/scorer_upload/kwon/copora/csj
CSJ_ROOT=$KALDI_ROOT/egs/csj/s5
CSJVER=usb  ## Set your CSJ format (dvd or usb).
            ## Usage    :
            ## Case DVD : We assume CSJ DVDs are copied in this directory with the names dvd1, dvd2,...,dvd17.
            ##            Neccesary directory is dvd3 - dvd17.
            ##            e.g. $ ls $CSJDATATOP(DVD) => 00README.txt dvd1 dvd2 ... dvd17
            ##
            ## Case USB : Neccesary directory is MORPH/SDB and WAV
            ##            e.g. $ ls $CSJDATATOP(USB) => 00README.txt DOC MORPH ... WAV fileList.csv
            ## Case merl :MERL setup. Neccesary directory is WAV and sdb

if [ ! -e data/csj-data/.done_make_all ]; then
 echo "CSJ transcription file does not exist"
 #local/csj_make_trans/csj_autorun.sh <RESOUCE_DIR> <MAKING_PLACE(no change)> || exit 1;
 $CSJ_ROOT/local/csj_make_trans/csj_autorun.sh $CSJDATATOP data/csj-data $CSJVER
fi
wait

[ ! -e data/csj-data/.done_make_all ]\
    && echo "Not finished processing CSJ data" && exit 1;

# Prepare Corpus of Spontaneous Japanese (CSJ) data.
# Processing CSJ data to KALDI format based on switchboard recipe.
# local/csj_data_prep.sh <SPEECH_and_TRANSCRIPTION_DATA_DIRECTORY>
$CSJ_ROOT/local/csj_data_prep.sh data/csj-data

# Data preparation and formatting for evaluation set.
# CSJ has 3 types of evaluation data
#local/csj_eval_data_prep.sh <SPEECH_and_TRANSCRIPTION_DATA_DIRECTORY_ABOUT_EVALUATION_DATA> <EVAL_NUM>
for eval_num in eval1 eval2 eval3 ; do
    $CSJ_ROOT/local/csj_eval_data_prep.sh data/csj-data/eval $eval_num
done

for x in train eval1 eval2 eval3; do
  KDATA=data/$x;LDATA=exp/log;FDATA=data/$x"_"fbank
  steps/make_fbank.sh --cmd "$train_cmd" --nj 44 $KDATA $LDATA $FDATA || exit 1;
  utils/fix_data_dir.sh $KDATA || exit;
  steps/compute_cmvn_stats.sh $KDATA $LDATA $FDATA || exit 1;

  echo "Feature precessing $x done!"
  norm_vars=true
  add_deltas=true

  feats_tr="ark,s,cs:apply-cmvn --norm-vars=$norm_vars --utt2spk=ark:$KDATA/utt2spk \
              scp:$KDATA/cmvn.scp scp:$KDATA/feats.scp ark:- |"
  tmpdir=$(mktemp -d /tmp/XXX);
  copy-feats "$feats_tr" ark,scp:$tmpdir/tmp.ark,$LDATA/tmp"_"norm.scp || exit 1;
  #copy-feats scp:$LDATA/tmp"_"norm.scp ark,t:- > $FDATA"40.txt"
  if $add_deltas; then
    copy-feats scp:$LDATA/tmp"_"norm.scp ark,t:- | add-deltas ark,t:- ark,t:- > $FDATA"120.txt"
  fi

  rm -rf $tmpdir
  rm -f $LDATA/tmp"_"norm.scp

  echo "Feature text extraction $x done!"
done

for x in eval1 eval2 eval3 train;do
  local/GetTrans.sh data/$x/text data/$x.trans

  awk '{print $1}' data/$x.trans > data/$x.transid

  python local/GetAligned.py data/$x"_"fbank120.txt data/$x.transid
  rm -f data/$x.transid

  local/CheckID.sh data/$x"_"fbank120v5.txt data/$x.trans
  local/GetSeqLength.sh data/$x"_"fbank120v5.txt data/$x.trans

done

#data/eval1_fbank120.txt data/eval1.transid data/eval1_fbank120v5.txt
#Difference between data/eval1_fbank120v5.txt and data/eval1.trans is:
#data/eval1_fbank120v5.txt - max of feature frame length: 1690
#data/eval1.trans - max of transcription sequence length: 809
#data/eval2_fbank120.txt data/eval2.transid data/eval2_fbank120v5.txt
#Difference between data/eval2_fbank120v5.txt and data/eval2.trans is:
#data/eval2_fbank120v5.txt - max of feature frame length: 1689
#data/eval2.trans - max of transcription sequence length: 773
#data/eval3_fbank120.txt data/eval3.transid data/eval3_fbank120v5.txt
#Difference between data/eval3_fbank120v5.txt and data/eval3.trans is:
#data/eval3_fbank120v5.txt - max of feature frame length: 1592
#data/eval3.trans - max of transcription sequence length: 833
#data/train_fbank120.txt data/train.transid data/train_fbank120v5.txt
#Difference between data/train_fbank120v5.txt and data/train.trans is:
#data/train_fbank120v5.txt - max of feature frame length: 2503
#data/train.trans - max of transcription sequence length: 1037

dline=1000
cat data/eval1_fbank120v5.txt data/eval2_fbank120v5.txt data/eval3_fbank120v5.txt > data/eval_fbank120v5.txt
grep -nr "\[" data/eval_fbank120v5.txt > data/eval.sid
grep -nr "\]" data/eval_fbank120v5.txt > data/eval.eid
dlinef=$(head -n $dline data/eval.eid | tail -n 1 | sed 's/:.*//g')
head -n $dlinef data/eval_fbank120v5.txt > data/dev_fbank120v5.txt
elinef=$(wc -l data/eval_fbank120v5.txt | sed 's/ .*//g')
tail -n $((elinef-dlinef)) data/eval_fbank120v5.txt > data/test_fbank120v5.txt

cat data/eval1.trans data/eval2.trans data/eval3.trans > data/eval.trans
head -n $dline data/eval.trans > data/dev.trans
eline=$(wc -l data/eval.trans | sed 's/ .*//g')
tail -n $((eline - dline)) data/eval.trans > data/test.trans

local/CheckID.sh data/dev_fbank120v5.txt data/dev.trans
local/CheckID.sh data/test_fbank120v5.txt data/test.trans


