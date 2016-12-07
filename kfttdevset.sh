#3.5.1  Generating the 1-Best WFSAs
#We process the entire 1700 sentence dev set in batch mode. The following step generates 1700 WFSAs with the best-scoring mixed case character sequence for each sentence.
mkdir kftt.hyps.lm.char.2
for id in `seq 1 1113`; do
fstcompose $DIR/data/kftt/kftt-dev.input.fsts/$id.fst toUpper.lm.char.2.fst |\
fstproject --project_output | fstshortestpath > kftt.hyps.lm.char.2/$id.fst
done

#3.5.2  Generating Character Sequence Hypotheses
printstrings --range=1:1113 --input=kftt.hyps.lm.char.2/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lm.char.2/rawhyps

#3.5.3  Remove the Sentence Start and Sentence End Symbols
sed 's,<s>,,;s,</s>,,' kftt.hyps.lm.char.2/rawhyps > kftt.hyps.lm.char.2/chyps

sed 's, ,,g;s,_, ,g' kftt.hyps.lm.char.2/chyps > kftt.hyps.lm.char.2/whyps

python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.char.2/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

#3.6.2  Performance at the Word Level
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.char.2/whyps \
--ref $DIR/data/kftt/kftt-dev.words

#Build transducers to map mixed-cased character sequences to mixed-case word sequences for the sentences in the development set:
mkdir -p kfttcseq2wseq/
for id in `seq 1 1113`; do
fstcompose $DIR/data/kftt/kftt-dev.input.fsts/$id.fst toUpper.fst |\
fstproject --project_output | fstcompose - cseq2wseq.fst > kfttcseq2wseq/$id.fst
done

#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p kftt.hyps.lm.words.1
for id in `seq 1 1113`; do
fstcompose kfttcseq2wseq/$id.fst lm.word.1.fst | fstshortestpath > kftt.hyps.lm.words.1/$id.fst
done

# Generate and score the mixed-case character sequences
printstrings --range=1:1113 --input=kftt.hyps.lm.words.1/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lm.words.1/rawhyps
sed 's,<s>,,;s,</s>,,'   kftt.hyps.lm.words.1/rawhyps > kftt.hyps.lm.words.1/chyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.words.1/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  kftt.hyps.lm.words.1/chyps > kftt.hyps.lm.words.1/whyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.words.1/whyps \
--ref $DIR/data/kftt/kftt-dev.words

#########################################################################################
#5 Recasing and Lattice Rescoring
#########################################################################################

#5.1  Character Lattice Generation Under the Character Bigram Language Model
mkdir -p kftt.lats.lm.char.2
for id in `seq 1 1113`; do
fstcompose $DIR/data/kftt/kftt-dev.input.fsts/$id.fst toUpper.lm.char.2.fst |\
fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > kftt.lats.lm.char.2/$id.fst
done

#5.2  Word Lattice Generation Under the Word Unigram Language Model
mkdir -p kftt.lats.lm.word.1
for id in `seq 1 1113`; do
fstcompose kfttcseq2wseq/$id.fst lm.word.1.fst | fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > kftt.lats.lm.word.1/$id.fst
done

#################################################################################
#2-char 1-word evaluation
#################################################################################
#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p kftt.hyps.lats.lm.words.1
mkdir -p kftt.hyps.lats.lm.charwords.1
for id in `seq 1 1113`; do
#fstcompose kfttcseq2wseq/$id.fst kftt.lats.lm.word.1/$id.fst | fstshortestpath > kftt.hyps.lats.lm.words.1/$id.fst
fstcompose kftt.lats.lm.char.2/$id.fst kfttcseq2wseq/$id.fst > kftt.hyps.lats.lm.charwords.1/$id.fst
fstcompose kftt.hyps.lats.lm.charwords.1/$id.fst kftt.lats.lm.word.1/$id.fst  > kftt.hyps.lats.lm.words.1/$id.fst
done

# Generate and score the mixed-case character sequences
printstrings --range=1:1113 --input=kftt.hyps.lats.lm.words.1/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lats.lm.words.1/rawhyps
sed 's,<s>,,;s,</s>,,'  kftt.hyps.lats.lm.words.1/rawhyps > kftt.hyps.lats.lm.words.1/chyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.1/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  kftt.hyps.lats.lm.words.1/chyps > kftt.hyps.lats.lm.words.1/whyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.1/whyps \
--ref $DIR/data/kftt/kftt-dev.words

#################################################################################
# Generate Bigram Word model
#################################################################################
mkdir -p kftt.lats.lm.word.2
for id in `seq 1 1113`; do
fstcompose kfttcseq2wseq/$id.fst lm.word.2.fst | fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > kftt.lats.lm.word.2/$id.fst
done


#################################################################################
#Evaluation of 2-gram char 2-gram word model - Interpolation
#################################################################################
#TODO
#Batch processing of the dev set follows the procedure for the character-based LM: DONE
mkdir -p kftt.hyps.lats.lm.words.2
for id in `seq 1 1113`; do
#fstcompose kfttcseq2wseq/$id.fst lats.lm.word.1/$id.fst | fstshortestpath > kftt.hyps.lats.lm.words.1/$id.fst
fstcompose kftt.hyps.lats.lm.charwords.1/$id.fst kftt.lats.lm.word.2/$id.fst  > kftt.hyps.lats.lm.words.2/$id.fst
done

# Generate and score the mixed-case character sequences
printstrings --range=1:1113 --input=kftt.hyps.lats.lm.words.2/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lats.lm.words.2/rawhyps
sed 's,<s>,,;s,</s>,,'  kftt.hyps.lats.lm.words.2/rawhyps > kftt.hyps.lats.lm.words.2/chyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.2/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  kftt.hyps.lats.lm.words.2/chyps > kftt.hyps.lats.lm.words.2/whyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.2/whyps \
--ref $DIR/data/kftt/kftt-dev.words



