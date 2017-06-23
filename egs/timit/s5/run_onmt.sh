#!/bin/bash

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
./run_feat_extract.sh

for xx in test dev train
do
  for ft in mfcc39 fbank40 fbank120
  do
    echo "build target for $xx with $ft"
    onmt/build_tgt.sh onmt/data/$xx.$ft
    echo "validate src & tgt for $xx with $ft"
    onmt/correct_srctgt.sh onmt/data/$xx.$ft onmt/data/$xx.tgt
  done
done

