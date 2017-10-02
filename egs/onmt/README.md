# Training data preparation for OpenNMT
This repository has a script which produces source file (i.e. acoustic feature vector) and target file to be used for OpenNMT training.

## Kaldi installation

Details of the Kaldi installation are described [HERE](http://kaldi-asr.org/doc/install.html).

## WSJ corpus

### Description
Details of WSJ corpus are [LDC93S6B](https://catalog.ldc.upenn.edu/LDC93S6B) and [LDC94S13B](https://catalog.ldc.upenn.edu/LDC94S13B). I hope you have permission to use it.

In this repository, you need to define where WSJ corpus is located in: [run.wsj](https://github.com/homink/kaldi/blob/FeatureText/egs/onmt/s5/run_wsj.sh)

As default, train_si284 and test_eval92 will be produced WSJ corpus. dev set is part of test_eval92. If you set 'build_all=1' in [run.wsj](https://github.com/homink/kaldi/blob/FeatureText/egs/onmt/s5/run_wsj.sh), only 1 set will be produced all together. The dimension of acoustic feacture vector is 40 as default as well. If you need only 40 dimension, set 'add_deltas=false' in [extract_feat2lmfb.sh](https://github.com/homink/kaldi/blob/FeatureText/egs/onmt/s5/local/extract_feat2lmfb.sh) for time saving.

### Execution

You can simply run the following script. 

```bash
cd onmt
./run_wsj.sh
```

Then you will find files stored in data directory. You will see the following contents.
```
>> head -n 3 data/wsj_train_fbank_fbank40.txt
corpus_011c0201  [
  -1.633 -1.801528 -1.710642 -1.829233 -2.054341 -1.967825 -1.564008 -1.579484 -1.317073 -1.317378 -1.202563 -1.251416 -1.563277 -1.232364 -1.15947 -1.119517 -0.8444872 -1.244048 -1.15592 -0.9996397 -1.080801 -1.163208 -1.240158 -1.053543 -1.143746 -1.097637 -1.23324 -1.271396 -1.460034 -1.064553 -1.293299 -1.284685 -1.161613 -0.9018159 -0.9154592 -0.6262932 -0.9791899 -0.9417715 -1.016841 -0.8425808
  -1.869808 -2.099066 -1.908961 -1.883852 -1.608039 -1.674608 -1.377497 -1.466071 -1.45024 -1.631475 -1.469867 -1.220468 -1.510914 -1.536926 -1.349768 -1.038678 -1.134337 -1.276435 -1.15592 -1.131665 -1.239906 -1.321429 -0.9671359 -1.053543 -1.407538 -1.196236 -1.044097 -1.163179 -1.382647 -1.217748 -1.293299 -1.34128 -1.001687 -0.7888751 -0.9535823 -0.8489699 -0.9394794 -0.969873 -0.9885826 -0.8505435
  
>>  head -n 3 data/wsj_train_fbank_trans.txt
corpus_011c0201 t h e _ s a l e _ o f _ t h e _ h o t e l s _ i s _ p a r t _ o f _ h o l i d a y ' s _ s t r a t e g y _ t o _ s e l l _ o f f _ a s s e t s _ a n d _ c o n c e n t r a t e _ o n _ p r o p e r t y _ m a n a g e m e n t
corpus_011c0202 t h e _ h o t e l _ o p e r a t o r ' s _ e m b a s s y _ s u i t e s _ h o t e l s _ i n c o r p o r a t e d _ s u b s i d i a r y _ w i l l _ c o n t i n u e _ t o _ m a n a g e _ t h e _ p r o p e r t i e s
corpus_011c0203 l o n g _ t e r m _ m a n a g e m e n t _ c o n t r a c t s _ a l l o w _ u s _ t o _ g e n e r a t e _ i n c o m e _ o n _ a _ s i g n i f i c a n t l y _ l o w e r _ c a p i t a l _ b a s e _ s a i d _ m i c h a e l _ d . _ r o s e _ h o l i d a y ' s _ c h a i r m a n _ a n d _ c h i e f _ e x e c u t i v e _ o f f i c e r

>> head -n 3 data/wsj_test_fbank_fbank40.txt
corpus_440c0401  [
  -1.310421 -1.249478 -0.9921916 -0.9762827 -1.378478 -1.46874 -1.258672 -0.9971293 -1.168064 -0.9534788 -1.111557 -0.9289469 -1.076174 -1.105152 -1.145581 -1.194425 -0.8483632 -1.106837 -1.252971 -1.234793 -1.112116 -0.928268 -1.0648 -1.192435 -0.8566706 -0.8075054 -0.9908807 -0.896461 -0.9776967 -0.9720323 -1.071319 -1.099703 -1.109831 -1.062183 -0.8463089 -0.8614404 -1.019695 -1.082448 -0.8810923 -0.8579264
  -1.332009 -1.269075 -1.126766 -1.190791 -0.9753066 -1.17888 -1.314318 -1.28046 -1.207158 -0.980239 -0.9530563 -0.9756705 -1.089389 -1.074475 -1.059091 -1.092476 -0.9455318 -0.9480152 -0.990151 -0.9255195 -0.8703418 -1.024614 -1.023826 -1.140431 -1.113094 -0.8177481 -1.182275 -0.9600432 -1.106123 -0.9812462 -1.028892 -1.044649 -1.313421 -0.9328926 -0.8977475 -0.9782937 -1.154951 -1.033998 -0.9445779 -0.9626322
  
>> head -n 3 data/wsj_test_fbank_trans.txt
corpus_440c0401 d r a v o _ l a s t _ m o n t h _ a g r e e d _ i n _ p r i n c i p l e _ t o _ s e l l _ i t s _ i n l a n d _ w a t e r _ t r a n s p o r t a t i o n _ s t e v e d o r i n g _ a n d _ p i p e _ f a b r i c a t i o n _ b u s i n e s s e s _ f o r _ a n _ u n d i s c l o s e d _ s u m
corpus_440c0402 t h e _ c o m b i n e d _ b u s i n e s s e s _ a c c o u n t e d _ f o r _ t w o _ h u n d r e d _ t h i r t y _ f i v e _ m i l l i o n _ d o l l a r s _ o f _ d r a v o ' s _ e i g h t _ h u n d r e d _ n i n e t y _ t h r e e _ m i l l i o n _ d o l l a r s _ i n _ n i n e t e e n _ e i g h t y _ f i v e _ r e v e n u e
corpus_440c0403 i n _ s e p t e m b e r _ t h e _ c o m p a n y _ r e c e i v e d _ n i n e t y _ s i x _ p o i n t _ e i g h t _ m i l l i o n _ d o l l a r s _ a s _ i t s _ s h a r e _ o f _ d a m a g e s _ f r o m _ a _ b r e a c h _ o f _ c o n t r a c t _ a w a r d _ r e l a t e d _ t o _ a _ c o a l _ p a r t n e r s h i p
```
