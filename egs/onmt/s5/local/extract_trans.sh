
# ex) ./extract_feat2text.sh wsj.table data/wsj exp/make_fbank/wsj


echo "
  Transcription data preparation...
"
KDATA=$1
FDATA=$2
mkdir -p $KDATA
mkdir -p $FDATA

echo "Converting transcription to be used for OpenNMT ..."
awk '{print $1}' $KDATA/text > temp.uid

if [ "$(head -n 1 $KDATA/text | grep -o '_' | wc -l)" -gt 3 ]; then
  echo "Already formatted"
  awk '{$1=""}1' $KDATA/text | sed 's/^ //g' > temp.trans
else
  awk '{$1=""}1' $KDATA/text | sed 's/^ //g;s/ /_/g;s/./& /g;s/\(.*\)/\L\1/g' > temp.trans
fi
paste -d' ' temp.uid temp.trans > $FDATA"_"trans.txt
rm -f temp.uid temp.trans
echo "Done"
