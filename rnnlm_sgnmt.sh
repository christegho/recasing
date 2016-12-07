#6 Recasing with a TensorFlow RNN LM and SGNMT
export HiFST=/home/wjb31/src/hifst/hifst.mlsalt-cpu2.18Oct16/ucam-smt/
# path to the UCAM HiFST translation binaries
export PATH=$PATH:$HiFST/bin/
# path to the OpenFST binaries
export PATH=$PATH:$HiFST/externals/openfst-1.5.4/INSTALL_sDIR/bin/

alias printstrings=printstrings.sta.O2.bin

DIR=/home/wjb31/MLSALT/MLSALT3/practical/recasing

########################################################################
mkdir -p tf.exps/configs ; cd tf.exps
cp $DIR/configs/* configs/

#6.1 Training a Character-based RNN LM with TensorFlow IGNORED

$DIR/scripts/train_rnnlm_chars.sh -USEGPUID 1 >& train_char_rnnlm.log &

#6.2.1  Lattice Shortest Path Search with SGNMT
tar xzvf $DIR/common/train.rnnlm.chars.tgz
source /home/ech57/tools/scripts/tf_helper_cpu.sh
python /home/ech57/tools/sgnmt/decode.py \
--config_file ./configs/sgnmt.default.ini \
--predictors fst --fst_path ../lats.lm.word.1/%d.fst \
--use_fst_weights true --range 1:5 --output_path tmp.%s

#6.2.2 SGNMT Lattice Decoding with the TensorFlow RNN LM
#sent 21
source /home/ech57/tools/scripts/tf_helper_cpu.sh
python /home/ech57/tools/sgnmt/decode.py \
--config_file configs/sgnmt.rnnlm_chars.dev.ini --range=21:21 \
--output_path tmp.%s  --use_fst_weights true  --outputs=sfst
source deactivate

printstrings -m $DIR/data/chars.syms -n 5 -u -w < tmp.sfst/21.fst

####################################################################
#6.2.3 Parallel SGNMT Decoding
####################################################################
$DIR/scripts/sgnmt_on_grid_cpu.sh 340 1700 \
lats.lm.char.2.rnnlm configs/sgnmt.rnnlm_chars.dev.ini

#Scoring is done in the usual way:
# generate raw character hypotheses
printstrings -m $DIR/data/chars.syms --range=1:1700 \
--input=lats.lm.char.2.rnnlm/sfst/?.fst --output=lats.lm.char.2.rnnlm/rawhyps
# generate and score character hypotheses
sed 's,<s>,,;s,</s>,,'  lats.lm.char.2.rnnlm/rawhyps > lats.lm.char.2.rnnlm/chyps
python $DIR/scripts/eval_recasing.py --test lats.lm.char.2.rnnlm/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

# generate and score word hypotheses
sed 's, ,,g;s,_, ,g' lats.lm.char.2.rnnlm/chyps > lats.lm.char.2.rnnlm/whyps
python $DIR/scripts/eval_recasing.py --test lats.lm.char.2.rnnlm/whyps \
--ref $DIR/data/ptb/ptb-dev.words

####################################################################
#6.2.3 Parallel SGNMT Decoding - evaluating on KFTT
####################################################################
$DIR/scripts/sgnmt_on_grid_cpu.sh 340 1113 \
kftt.lats.lm.char.2.rnnlm configs/sgnmt.rnnlm_chars.dev.ini

#Scoring is done in the usual way:
# generate raw character hypotheses
printstrings -m $DIR/data/chars.syms --range=1:1113 \
--input=kftt.lats.lm.char.2.rnnlm/sfst/?.fst --output=kftt.lats.lm.char.2.rnnlm/rawhyps
# generate and score character hypotheses
sed 's,<s>,,;s,</s>,,'  kftt.lats.lm.char.2.rnnlm/rawhyps > kftt.lats.lm.char.2.rnnlm/chyps
python $DIR/scripts/eval_recasing.py --test kftt.lats.lm.char.2.rnnlm/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# generate and score word hypotheses
sed 's, ,,g;s,_, ,g' kftt.lats.lm.char.2.rnnlm/chyps > kftt.lats.lm.char.2.rnnlm/whyps
python $DIR/scripts/eval_recasing.py --test kftt.lats.lm.char.2.rnnlm/whyps \
--ref $DIR/data/kftt/kftt-dev.words
