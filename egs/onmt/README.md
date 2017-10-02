# Training data preparation for OpenNMT
This repository has a script which produces source file (i.e. acoustic feature vector) and target file to be used for OpenNMT training.

## Kaldi installation

Details of the Kaldi installation are described [HERE](http://kaldi-asr.org/doc/install.html).


## LibriSpeech corpus

Details of LibriSpeech corpus are [here](http://www.openslr.org/12/), which has license CC BY 4.0.

In this repository, you need to define where LibriSpeech corpus is located in: [run_libri.sh](https://github.com/homink/kaldi/blob/FeatureText/egs/onmt/s5/run_libri.sh)

As default(libri_set=1), 3 sets of data (dev-clean test-clean train-clean-10) will be produced. libri_set=2 and 3 will proudce more data depending upon your preference. Both 40 dimension and 120 dimensional acoustic feacutre vector data will be produced. If you need only 40 dimension, set 'add_deltas=false' in [extract_feat2lmfb.sh](https://github.com/homink/kaldi/blob/FeatureText/egs/onmt/s5/local/extract_feat2lmfb.sh) for time saving.

### Execution

You can simply run the following script. 

```bash
cd onmt
./run_libri.sh
```

Then you will find files stored in data directory. You will see the following contents.
```
>> head -n 3 libri_train-clean-100_fbank_fbank120.txt
corpus_103-1240-0000  [
  0.468585 -0.4079704 -1.620145 -1.056782 -0.9097733 -1.12344 -1.359877 -1.43579 -1.311097 -1.37946 -1.121691 -1.078407 -1.053598 -1.141079 -1.081761 -1.150753 -0.919507 -1.37128 -1.420133 -1.272654 -1.295049 -1.16443 -1.382529 -1.374385 -1.303482 -1.282272 -1.127109 -1.486927 -1.040667 -1.145697 -1.035639 -0.9005504 -1.0413 -0.8917689 -0.9616466 -0.8547287 -0.8086925 -0.8019128 -0.6154175 -0.755805 0.09406798 0.1589294 0.1711227 -0.0597223 -0.04936521 0.03004873 0.08644514 0.07167596 -0.05019762 0.03947116 0.07794262 0.02555074 -0.01838017 -0.05831993 -0.06530471 -0.06174928 -0.1229105 0.06282358 0.02500528 0.06560294 0.01566927 0.008892104 0.05576858 0.04342589 -0.007659882 -0.009699136 -0.03047675 0.09016979 -0.03897098 0.05338173 -0.03060769 -0.03198445 0.02686957 -0.004091576 0.05923092 0.04176888 -0.05137101 0.01585801 -0.001967348 0.06046762 0.01231035 0.02682239 0.02420518 -0.00060229 0.000417158 0.01129179 -0.01178727 -0.01264875 0.01523234 0.04632061 0.008092385 0.01051122 -0.01142194 -0.02304351 -0.01447296 -0.01234985 0.003452554 0.03444667 0.008168418 -0.01647051 0.006410129 -0.01507286 -0.008492019 -0.005526945 -0.0214486 -0.0312594 -0.02295921 0.03193261 0.002814565 0.001315285 -0.02264962 -0.02135732 0.003307015 0.0006546453 0.008698758 0.0009366106 0.01943531 0.01777175 0.0128533 0.004766287
  0.7241583 0.07405472 -1.084162 -1.108261 -1.107234 -1.301428 -1.258741 -1.224978 -1.813073 -1.622362 -0.9581397 -0.9304819 -1.053598 -1.098406 -1.24061 -1.305126 -1.292382 -1.37128 -1.336782 -1.007451 -1.280804 -0.996089 -1.154385 -1.413864 -1.277947 -0.9507375 -1.147427 -1.497455 -1.213871 -1.134866 -0.9744239 -0.9108677 -1.020631 -0.9326844 -0.8601079 -0.6227679 -1.0313 -0.8283424 -0.7924786 -0.5921869 0.08269378 0.1689546 0.1866141 0.02762356 0.001263037 0.01947416 -0.01384702 0.03091896 -0.01730964 0.1100864 0.06591047 0.04303272 -0.08008468 -0.1536234 -0.1235493 -0.1119206 -0.0925281 0.0613278 -0.008335143 -0.00837487 0.02136721 -0.01985519 0.03422168 0.02368689 -0.06638828 -0.06642127 -0.04876286 0.09824872 -0.002164975 0.0109867 -0.06427601 -0.02785733 -0.004133865 -0.02127613 0.09130147 0.03714561 0.007705525 0.06573258 0.02623124 0.03628059 -0.02468817 -0.03932726 -0.04777548 -0.0114111 -0.003145617 0.003557123 -0.03087015 -0.05171921 0.04725494 0.02350745 -0.02408447 0.001657702 0.003807299 0.0106683 0.01235488 0.01485842 0.05303106 0.02502313 0.01016886 -0.03740761 0.008974116 -0.01868729 -0.02040618 -0.009737909 -0.01123511 -0.04568777 -0.01473048 0.006074041 0.01125829 -0.007968731 -0.01515076 -0.02146051 0.0004133768 0.008592281 -0.01087726 -0.01143425 0.05096482 0.009960163 0.01101713 -0.01593498
  
>> head -n 3 libri_train-clean-100_fbank_trans.txt
corpus_103-1240-0000 c h a p t e r _ o n e _ m i s s u s _ r a c h e l _ l y n d e _ i s _ s u r p r i s e d _ m i s s u s _ r a c h e l _ l y n d e _ l i v e d _ j u s t _ w h e r e _ t h e _ a v o n l e a _ m a i n _ r o a d _ d i p p e d _ d o w n _ i n t o _ a _ l i t t l e _ h o l l o w _ f r i n g e d _ w i t h _ a l d e r s _ a n d _ l a d i e s _ e a r d r o p s _ a n d _ t r a v e r s e d _ b y _ a _ b r o o k
corpus_103-1240-0001 t h a t _ h a d _ i t s _ s o u r c e _ a w a y _ b a c k _ i n _ t h e _ w o o d s _ o f _ t h e _ o l d _ c u t h b e r t _ p l a c e _ i t _ w a s _ r e p u t e d _ t o _ b e _ a n _ i n t r i c a t e _ h e a d l o n g _ b r o o k _ i n _ i t s _ e a r l i e r _ c o u r s e _ t h r o u g h _ t h o s e _ w o o d s _ w i t h _ d a r k _ s e c r e t s _ o f _ p o o l _ a n d _ c a s c a d e _ b u t _ b y _ t h e _ t i m e _ i t _ r e a c h e d _ l y n d e ' s _ h o l l o w _ i t _ w a s _ a _ q u i e t _ w e l l _ c o n d u c t e d _ l i t t l e _ s t r e a m
corpus_103-1240-0002 f o r _ n o t _ e v e n _ a _ b r o o k _ c o u l d _ r u n _ p a s t _ m i s s u s _ r a c h e l _ l y n d e ' s _ d o o r _ w i t h o u t _ d u e _ r e g a r d _ f o r _ d e c e n c y _ a n d _ d e c o r u m _ i t _ p r o b a b l y _ w a s _ c o n s c i o u s _ t h a t _ m i s s u s _ r a c h e l _ w a s _ s i t t i n g _ a t _ h e r _ w i n d o w _ k e e p i n g _ a _ s h a r p _ e y e _ o n _ e v e r y t h i n g _ t h a t _ p a s s e d _ f r o m _ b r o o k s _ a n d _ c h i l d r e n _ u p

>> head -n 3 libri_dev-clean_fbank_fbank120.txt
corpus_1272-128104-0000  [
  -1.382718 -1.461141 -1.772609 -1.984158 -1.707471 -1.585969 -1.692197 -1.249631 -1.123553 -1.110775 -1.025201 -0.7500331 -0.6576283 -1.101274 -1.327171 -1.059432 -0.5769253 -0.3316336 -0.3020861 -0.7530258 -1.008794 -0.7821424 -0.4323449 -0.6889861 -0.8113263 -0.7046931 -1.050425 -1.007254 -1.425343 -0.9703672 -1.016424 -0.8404107 -0.7393174 -0.7945654 -0.8761168 -1.481528 -1.605667 -1.619576 -1.506725 -1.546156 0.03138067 0.01170608 0.05466571 0.1285271 0.08861521 0.0589242 0.03821236 -0.121837 -0.1043642 -0.04728389 -0.03483741 -0.05792778 -0.08619718 -0.03600948 0.005321205 0.03012283 0.07018004 0.02476112 0.09526213 0.1446929 0.0574825 0.00684613 0.02298015 0.1199479 0.06921227 -0.08899666 -0.06874491 -0.09301092 -0.03823343 -0.01312152 0.1001683 0.09768115 0.01410794 0.009886235 5.960464e-08 0.01066539 0.008149892 -0.002334714 0.01030579 -0.008963257 0.004034624 0.005735978 0.01811771 0.03798261 0.01791995 -0.004299894 0.02344861 0.001661435 -0.0110595 -0.003039669 0.001393501 -0.01144233 -0.03068247 0.01008272 0.006917454 0.01079397 0.003508994 -0.02063428 -0.04756846 -0.01743058 0.02319111 0.01004094 0.01947837 0.02125202 0.01149503 -0.003371961 0.01374902 -0.02446593 -0.01650082 -0.004686229 0.01411729 0.01852215 0.01987197 0.003954478 -0.01408638 0.004113819 0.01976306 -0.002101243 -0.003916141 0.01053187
  -1.397661 -1.648438 -1.850702 -1.696411 -1.412087 -1.410789 -1.553243 -1.471153 -1.326051 -1.245872 -1.280675 -1.043236 -0.9316328 -1.173293 -1.167537 -0.9088182 -0.3833251 -0.2019324 0.2074556 -0.1788478 -0.8881979 -0.7136812 -0.421402 -0.4260378 -0.637099 -0.8576319 -1.321238 -1.249891 -1.566203 -0.9141326 -0.6407924 -0.6592031 -0.8264933 -0.695703 -0.799974 -1.466292 -1.564918 -1.596229 -1.444891 -1.590973 0.04333507 0.02224165 0.08121756 0.1496286 0.08861521 0.004777521 0.07121405 -0.07199459 -0.07009538 -0.02026448 0.009290025 -0.07294433 -0.1201617 0.009602711 0.04256892 0.05271481 0.05929004 -0.008253746 -0.0243694 0.09875858 0.1178429 -0.004564032 0.03720588 0.1123836 0.07526373 -0.03959697 0.01249921 -0.1031208 -0.06439334 -0.009372488 0.1112799 0.09426128 0.04364357 0.04201645 -0.01903561 0.001523495 0.04278609 0.01167369 0.01030576 0.02016744 -0.0001494661 0.01299372 0.005935013 0.0122772 -0.0005907752 -0.008122012 0.01615358 0.03433589 0.01510948 -0.00692369 -0.009057771 -0.007650241 -0.01287198 0.02472657 0.00239446 -0.002761282 -0.02831404 -0.03631633 -0.08223946 -0.07967147 0.001308138 0.01894084 0.01247489 -0.01552479 -0.01427872 0.02079806 0.04905102 0.02622603 0.008250333 -0.007123064 -0.01716247 -0.003588511 0.01456152 -0.01761044 -0.01370569 0.01416988 0.0305614 0.008638501 -0.002473403 0.0271139
  
>> head -n 3 libri_test-clean_fbank_trans.txt
corpus_1089-134686-0000 h e _ h o p e d _ t h e r e _ w o u l d _ b e _ s t e w _ f o r _ d i n n e r _ t u r n i p s _ a n d _ c a r r o t s _ a n d _ b r u i s e d _ p o t a t o e s _ a n d _ f a t _ m u t t o n _ p i e c e s _ t o _ b e _ l a d l e d _ o u t _ i n _ t h i c k _ p e p p e r e d _ f l o u r _ f a t t e n e d _ s a u c e
corpus_1089-134686-0001 s t u f f _ i t _ i n t o _ y o u _ h i s _ b e l l y _ c o u n s e l l e d _ h i m
corpus_1089-134686-0002 a f t e r _ e a r l y _ n i g h t f a l l _ t h e _ y e l l o w _ l a m p s _ w o u l d _ l i g h t _ u p _ h e r e _ a n d _ t h e r e _ t h e _ s q u a l i d _ q u a r t e r _ o f _ t h e _ b r o t h e l s
```

## WSJ corpus

### Description
Details of WSJ corpus are [LDC93S6B](https://catalog.ldc.upenn.edu/LDC93S6B) and [LDC94S13B](https://catalog.ldc.upenn.edu/LDC94S13B). I hope you have permission to use it.

In this repository, you need to define where WSJ corpus is located in: [run_wsj.sh](https://github.com/homink/kaldi/blob/FeatureText/egs/onmt/s5/run_wsj.sh)

As default, train_si284 and test_eval92 will be produced WSJ corpus. dev set is part of test_eval92. If you set 'build_all=1' in [run_wsj.sh](https://github.com/homink/kaldi/blob/FeatureText/egs/onmt/s5/run_wsj.sh), only 1 set will be produced all together. Both 40 dimension and 120 dimensional acoustic feacutre vector data will be produced. If you need only 40 dimension, set 'add_deltas=false' in [extract_feat2lmfb.sh](https://github.com/homink/kaldi/blob/FeatureText/egs/onmt/s5/local/extract_feat2lmfb.sh) for time saving.

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
  
>> head -n 3 data/wsj_train_fbank_trans.txt
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
