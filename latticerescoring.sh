#5 Recasing and Lattice Rescoring
export HiFST=/home/wjb31/src/hifst/hifst.mlsalt-cpu2.18Oct16/ucam-smt/
# path to the UCAM HiFST translation binaries
export PATH=$PATH:$HiFST/bin/
# path to the OpenFST binaries
export PATH=$PATH:$HiFST/externals/openfst-1.5.4/INSTALL_DIR/bin/

alias printstrings=printstrings.sta.O2.bin

DIR=/home/wjb31/MLSALT/MLSALT3/practical/recasing

#5.1  Character Lattice Generation Under the Character Bigram Language Model
mkdir -p lats.lm.char.2
for id in `seq 1 1700`; do
fstcompose $DIR/data/ptb/ptb-dev.input.fsts/$id.fst toUpper.lm.char.2.fst |\
fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > lats.lm.char.2/$id.fst
done

#5.2  Word Lattice Generation Under the Word Unigram Language Model
mkdir -p lats.lm.word.1
for id in `seq 1 1700`; do
fstcompose cseq2wseq/$id.fst lm.word.1.fst | fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > lats.lm.word.1/$id.fst
done

#5.2.1  Constrained Mapping from Word Lattices Back to Character Sequences
fstcompose lats.lm.char.2/21.fst cseq2wseq/21.fst  |\
printstrings -w -m $DIR/data/chars.syms  -n 5 -u
#<s> W e ' r e _ a b o u t _ t o _ s e e _ i f _ a d v e r t i s i n g _ w o r k s . </s> 101.67
#<s> W e ' r e _ a b o u t _ t o _ S e e _ i f _ a d v e r t i s i n g _ w o r k s . </s> 102.991
#<s> W e ' r e _ a b o u t _ t o _ s e e _ I f _ a d v e r t i s i n g _ w o r k s . </s> 102.995
#<s> W e ' r e _ a b o u t _ t o _ S e e _ I f _ a d v e r t i s i n g _ w o r k s . </s> 104.316
#<s> W e ' r e _ a b o u t _ t o _ s e e _ i f _ a d v e r t i s i n g _ W o r k s . </s> 104.586

fstcompose lats.lm.char.2/21.fst cseq2wseq/21.fst  hyps.lats.lm.words.1/21.fst
fstcompose  hyps.lats.lm.words.1/21.fst lats.lm.word.1/21.fst |\
printstrings -w -m $DIR/data/words.syms  -n 5 -u -p
#<s> We re about to see if advertising works </s> 	162.458
#<s> We re about to see If advertising works </s> 	164.532
#<s> We re about to See if advertising works </s> 	167.652
#<s> We re about to see if Advertising works </s> 	167.716
#<s> We re about to see if advertising Works </s> 	168.146

#################################################################################
#2-char 1-word evaluation
#################################################################################
#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p hyps.lats.lm.words.1
mkdir -p hyps.lats.lm.charwords.1
for id in `seq 1 1700`; do
#fstcompose cseq2wseq/$id.fst lats.lm.word.1/$id.fst | fstshortestpath > hyps.lats.lm.words.1/$id.fst
fstcompose lats.lm.char.2/$id.fst cseq2wseq/$id.fst > hyps.lats.lm.charwords.1/$id.fst
fstcompose hyps.lats.lm.charwords.1/$id.fst lats.lm.word.1/$id.fst  > hyps.lats.lm.words.1/$id.fst
done

# Generate and score the mixed-case character sequences
printstrings --range=1:1700 --input=hyps.lats.lm.words.1/?.fst -m $DIR/data/chars.syms \
--output=hyps.lats.lm.words.1/rawhyps
sed 's,<s>,,;s,</s>,,'  hyps.lats.lm.words.1/rawhyps > hyps.lats.lm.words.1/chyps
python $DIR/scripts/eval_recasing.py --test hyps.lats.lm.words.1/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  hyps.lats.lm.words.1/chyps > hyps.lats.lm.words.1/whyps
python $DIR/scripts/eval_recasing.py --test hyps.lats.lm.words.1/whyps \
--ref $DIR/data/ptb/ptb-dev.words

#################################################################################
# Generate Bigram Word model
#################################################################################
$DIR/tools/kenlm/bin/lmplz -o 2 < $DIR/data/train/train.words > lm.word.2.arpa
head -20 lm.word.2.arpa
LD_LIBRARY_PATH=$DIR/tools/kaldi/tools/openfst/lib/ \
$DIR/tools/kaldi/src/lmbin/arpa2fst \
--read-symbol-table=$DIR/data/words.syms lm.word.2.arpa - |\
fstarcsort - > lm.word.2.fst

fstinfo lm.word.2.fst | head

mkdir -p lats.lm.word.2
for id in `seq 1 1700`; do
fstcompose cseq2wseq/$id.fst lm.word.2.fst | fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > lats.lm.word.2/$id.fst
done

#Test with 21.fst
fstcompose cseq2wseq/21.fst lats.lm.word.2/21.fst |\
printstrings -w -m $DIR/data/words.syms  -n 5 -u -p
#<s> W e ' R e _ a b o u t _ t o _ s e e _ i f _ a d v e r t i s i n g _ w o r k s . </s> 62.6055
#<s> W e ' r e _ a b o u t _ t o _ s e e _ i f _ a d v e r t i s i n g _ w o r k s . </s> 64.5996
#<s> W e ' r E _ a b o u t _ t o _ s e e _ i f _ a d v e r t i s i n g _ w o r k s . </s> 64.5996
#<s> W e ' R E _ a b o u t _ t o _ s e e _ i f _ a d v e r t i s i n g _ w o r k s . </s> 64.5996
#<s> W e ' R e _ a b o u t _ t o _ s e e _ i f _ a d v e r t i s i n g _ W o r k s . </s> 64.6738
#<s> We Re about to see if advertising works </s> 	62.6055
#<s> We about to see if advertising works </s> 	64.5996
#<s> We Re about to see if advertising Works </s> 	64.6738
#<s> We Re about to see if Advertising works </s> 	64.9424
#<s> we Re about to see if advertising works </s> 	66.4805

#################################################################################
#Evaluation of 2-gram char 2-gram word model - Interpolation
#################################################################################
#Batch processing of the dev set follows the procedure for the character-based LM: DONE
mkdir -p hyps.lats.lm.words.2
for id in `seq 1 1700`; do
#fstcompose cseq2wseq/$id.fst lats.lm.word.1/$id.fst | fstshortestpath > hyps.lats.lm.words.1/$id.fst
fstcompose hyps.lats.lm.charwords.1/$id.fst lats.lm.word.2/$id.fst  > hyps.lats.lm.words.2/$id.fst
done

# Generate and score the mixed-case character sequences
printstrings --range=1:1700 --input=hyps.lats.lm.words.2/?.fst -m $DIR/data/chars.syms \
--output=hyps.lats.lm.words.2/rawhyps
sed 's,<s>,,;s,</s>,,'  hyps.lats.lm.words.2/rawhyps > hyps.lats.lm.words.2/chyps
python $DIR/scripts/eval_recasing.py --test hyps.lats.lm.words.2/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  hyps.lats.lm.words.2/chyps > hyps.lats.lm.words.2/whyps
python $DIR/scripts/eval_recasing.py --test hyps.lats.lm.words.2/whyps \
--ref $DIR/data/ptb/ptb-dev.words


#################################################################################
#testinput
file=in
fstcompile --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/chars.syms  --acceptor  $file.txt $file.fst
file2=heunk
file3=heheunk
fstcompose  ${file}.fst ${file2}.fst  ${file3}.fst
fstarcsort ${file3}.fst ${file3}2.fst
fstproject --project_output ${file3}2.fst ${file3}o.fst
printstrings -m $DIR/data/words.syms  -n 5 -u -p < ${file3}o.fst


#draw toUpper lm.char.2 21ToUpperLMTrunc 21ToUpperTrunc 21output2wseq
for file in  heheunk
do
#fstcompile --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/words.syms  ${file}.txt ${file}.fst
fstdraw --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/words.syms  ${file}.fst  ${file}.dot
dot -Tjpg  ${file}.dot >  ${file}.jpg
done
fstprint --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/words.syms  hyps.lats.lm.words.1/21.fst
fstcompose lats.lm.char.2/21.fst cseq2wseq/21.fst  hyps.lats.lm.words.1/21.fst


