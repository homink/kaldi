#!/bin/bash

./speech2lmfbs.sh --fbank_type fbank40 samples/4p0a0101_1.mp3 kaldi_data
./speech2lmfbs.sh samples/4p0a0101_3.wav kaldi_data
./speech2lmfbs.sh --fbank_type fbank120 samples/4p0a0101_2.wv1 kaldi_data
./speech2lmfbs.sh --fbank_type "fbank40 fbank120" samples/61-70970-0000.flac kaldi_data
./speech2lmfbs.sh samples/test.wma kaldi_data
