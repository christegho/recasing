#6 Recasing with a TensorFlow RNN LM and SGNMT
export HiFST=/home/wjb31/src/hifst/hifst.mlsalt-cpu2.18Oct16/ucam-smt/
# path to the UCAM HiFST translation binaries
export PATH=$PATH:$HiFST/bin/
# path to the OpenFST binaries
export PATH=$PATH:$HiFST/externals/openfst-1.5.4/INSTALL_DIR/bin/

alias printstrings=printstrings.sta.O2.bin

DIR=/home/wjb31/MLSALT/MLSALT3/practical/recasing


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
