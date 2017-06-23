# Acoustic Feature and Phone Annotation Extraction from the Kaldi

[Kaldi](http://kaldi-asr.org) has made use of special data preparation where audio and linguistic data are utilized for the ASR training. In order to use these data for other systems, we extract 3 types of normalized acoustic features (MFCC 39th, log Mel filter bank 40th, and log Mel filter bank 120th) and phone transcriptions. It is written for TIMIT corpus but not limited to others if available.

## Kaldi installation

Details of the Kaldi installation are described [HERE](http://kaldi-asr.org/doc/install.html).

## TIMIT corpus

Details of TIMIT corpus is [HERE](https://catalog.ldc.upenn.edu/ldc93s1). I hope you have permission to use it.

In this repository, you need to define where TIMIT corpus is located in 2 scripts files: [run_feat_extract.sh](https://github.com/homink/kaldi/blob/FeatureText/egs/timit/s5/run_feat_extract.sh) and [onmt/build_tgt.sh](https://github.com/homink/kaldi/blob/FeatureText/egs/timit/s5/onmt/build_tgt.sh).

## Execution

You can simply run the following script. 

```bash
./run_onmt.sh
```

This script performs
1. Re-align phone annotation sequence corresponding to the length of acoustic framing scheme (400 samples of window and 160 samples of shift at 16Khz)
2. Save normalized acoustic feature data into text format
3. Find mismatched sequences between acoustic feature and phone annotation
4. Produces 2 set of data:
   * Clean: no frame difference between acoustic feature and phone sequence
   * Noisy: 1 frame difference between acoustic feature and phone sequence

| Type              | Clean               | Noisy                |
| ----------------- |---------------------|----------------------|
| MFCC39            | train.mfcc39.clean  | train.mfcc39.noisy   |
|                   | dev.mfcc39.clean    | dev.mfcc39.noisy     |
|                   | test.mfcc39.clean   | test.mfcc39.noisy    |
| Log Mel fbank 40  | train.fbank40.clean | train.fbank40.noisy  |
|                   | dev.fbank40.clean   | dev.fbank40.noisy    |
|                   | test.fbank40.clean  | test.fbank40.noisy   |
| Log Mel fbank 120 | train.fbank120.clean | train.fbank120.noisy |
|                   | dev.fbank120.clean   | dev.fbank120.noisy   |
|                   | test.fbank120.clean  | test.fbank120.noisy  |
| Phone transcript  | train.tgt.clean      | train.tgt.noisy |
|                   | dev.tgt.clean        | dev.tgt.noisy   |
|                   | test.tgt.clean       | test.tgt.noisy  |

   * The above files are found in onmt/data and show the following contents.

```
>> head -n 3 train.mfcc39.clean
mejs0_sx70_dr8  [
  -1.777195 -0.7816529 0.5220026 -0.5140207 0.3541104 0.4244055 -0.84923 -0.6843433 -0.104683 1.019485 -0.3418208 0.2123014 0.9260948 -0.02428085 -0.05547372 0.04454677 0.05238588 -0.004109342 0.06764869 0.3820065 0.3277083 0.1536192 -0.08775477 0.02633248 0.2305038 0.1149994 -0.01896221 -0.01865936 0.01065784 -0.004000382 -0.007839333 -0.03405311 0.06381304 0.1089662 0.01589381 0.0132294 0.02987091 0.01309096 -0.03184944
  -1.835006 -0.9665653 0.7611145 -0.3330513 0.4539092 0.5335163 0.1139946 0.3762625 -0.006781481 0.2018618 -0.4570254 0.08428615 0.7314805 -0.06474885 -0.06219785 0.02192527 0.005714804 0.04579005 -0.02575069 0.3557044 0.4466022 0.1176019 -0.07490595 0.05677941 0.1006781 3.72529e-08 -0.01040611 0.003530134 0.001714792 -0.02285929 -0.002262343 -0.05015778 -0.06265472 -0.01230863 -0.04714954 0.03363147 0.03546657 -0.07689664 -0.09835535
  
>> head -n 3 train.tgt.noisy
mejs0_sx70_dr8 h# h# h# h# h# h# h# h# h# h# h# d d d d ih ih ih ih ih ih dcl dcl dcl dcl jh jh jh jh jh ux ux ux ux ux ux ux ux ux ux iy iy iy iy iy iy iy iy iy iy iy q q q q q y y y y y y y eh eh eh eh eh eh eh eh eh eh eh eh tcl tcl tcl tcl tcl tcl tcl tcl h# h# h# h# h# h# h#
mjmd0_si1658_dr2 h# h# h# h# h# h# h# h# h# h# h# h# w w w eh eh eh eh eh eh eh w w w w w w w ih ih ih ih ih ih ih ih dh dh dh dh dh ey ey ey ey ey ey ey ey ey n n n n n aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw aw h# h# h# h# h# h# h# h# h# h# h# h# h# h#
mmea0_si2018_dr8 h# h# h# h# h# h# h# h# h# h# h# dh dh dh ey ey ey ey ey ey ey ey ey w w w w w w axr axr axr axr axr sh sh sh sh sh sh sh sh sh sh sh sh sh ae ae ae ae ae ae ae ae ae ae ae ae ae dx dx dx axr axr axr axr axr axr axr axr dcl dcl dcl dcl dcl d d d d d d h# h# h# h# h# h# h# h# h# h# h# h# h# h# h# h# h#

>> head -n 3 test.fbank120.noisy
mdab0_sx229_dr1  [
  -2.234708 -1.91135 -1.668379 -1.49314 -1.179113 -1.205223 -1.127065 -0.801538 -0.715668 -0.7022052 -0.8765364 -1.356365 -1.468418 -1.545901 -1.340171 -1.298572 -1.390706 -1.482479 -1.292377 -1.019971 -1.134444 -1.579103 -1.603387 0.06106752 0.04228911 -0.04700741 -0.05094719 -0.008441016 -0.02977452 0.07151979 0.02694114 -0.08781458 -0.08604807 -0.06658041 -0.01174095 -0.00235182 -0.014346 -0.04463065 -0.08305709 -0.0271208 -0.03942361 -0.07083432 -0.08218619 -0.02825089 -0.008307427 0.007121593 0.01738078 0.005970232 0.006659351 0.009263158 -0.01645993 -0.02611004 -0.007152047 0.008713664 -0.007384613 -0.01888952 -0.02329217 -0.01690685 -0.005879171 -0.007582992 -0.008239552 -0.039551 -0.03817765 -0.008635737 -0.0210996 -0.02149288 -0.01840128 -0.007476471 0.008118656
  -2.093783 -1.687467 -1.746725 -1.81735 -1.179113 -1.044898 -0.8205516 -0.801538 -1.124402 -1.045885 -0.8584454 -1.28592 -1.633036 -1.648373 -1.511827 -1.496327 -1.369844 -1.801623 -1.518444 -1.290257 -1.218433 -1.628947 -1.560657 0.06106752 0.05472705 0.01175174 -0.02315769 -0.02954349 -0.07329132 -0.01532599 0.01347058 -0.07041176 -0.07325625 -0.07066907 -0.02817813 -0.01646179 -0.02664277 -0.04463074 -0.158204 -0.08970711 -0.06007421 -0.09946944 -0.081636 -0.06490079 -0.04153612 0.0213649 -0.002818488 -0.03208992 0.003917262 0.03172628 -0.02912144 -0.02771329 -0.01609197 0.01204723 0.0291381 0.0105749 -0.005456522 -0.02301206 -0.01481548 -0.009837396 -0.009784542 -0.02531262 -0.0358828 0.0140798 0.006179143 -0.0001318716 -0.005039368 0.002326123 0.002421349
```

5. Produces transcription files - 1) onmt/data/train.tgt.trans 2) onmt/data/dev.tgt.trans 3) onmt/data/test.tgt.trans

```
>> head -n 3 *.trans
==> dev.tgt.trans <==
mbwm0_si1934_dr3 w a i t _ a _ l i t t l e _ w h i l e
mglb0_si2164_dr3 t a k e _ c a r e _ o f _ y o u r s e l f _ t h e n
mjar0_si2247_dr2 w e a k n e s s _ i n _ l e a d e r s h i p

==> test.tgt.trans <==
mdab0_sx229_dr1 a r e _ y o u _ l o o k i n g _ f o r _ e m p l o y m e n t
mjdh0_si1984_dr6 a n d _ w h a t _ e y e s _ t h e y _ w e r e
mtas1_si1473_dr2 y o u _ d o n ' t _ e a t _ e n o u g h _ h o n e y

==> train.tgt.trans <==
mejs0_sx70_dr8 d i d _ y o u _ e a t _ y e t
mjmd0_si1658_dr2 w h e r e _ w e r e _ t h e y _ n o w
mmea0_si2018_dr8 t h e y _ w e r e _ s h a t t e r e d
```
