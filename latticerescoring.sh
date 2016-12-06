#5 Recasing and Lattice Rescoring

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
fstcompose cseq2wseq/21.fst lats.lm.word.1/21.fst |\
printstrings -w -m $DIR/data/chars.syms  -n 5 -u

#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p hyps.lats.lm.words.1
for id in `seq 1 1700`; do
fstcompose cseq2wseq/$id.fst lats.lm.word.1/$id.fst | fstshortestpath > hyps.lats.lm.words.1/$id.fst
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
fstprint --isymbols=$DIR/data/words.syms --osymbols=$DIR/data/words.syms  ${file3}o.fst

