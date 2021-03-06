export HiFST=/home/wjb31/src/hifst/hifst.mlsalt-cpu2.18Oct16/ucam-smt/
# path to the UCAM HiFST translation binaries
export PATH=$PATH:$HiFST/bin/
# path to the OpenFST binaries
export PATH=$PATH:$HiFST/externals/openfst-1.5.4/INSTALL_DIR/bin/

alias printstrings=printstrings.sta.O2.bin

DIR=/home/wjb31/MLSALT/MLSALT3/practical/recasing

$DIR/tools/printstrings --input=$DIR/data/ptb/ptb-dev.input.fsts/25.fst -m $DIR/data/chars.syms

#3.1 Build toUpper.fst to map character sequences from lower-case to mixed-case
fstcompile --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/chars.syms \
--keep_isymbols --keep_osymbols $DIR/common/toUpper.txt > toUpper.fst

#verify that the upper casing transducer does the right thing, for example :
printstrings --input=$DIR/data/ptb/ptb-dev.input.fsts/21.fst -m $DIR/data/chars.syms
fstcompose $DIR/data/ptb/ptb-dev.input.fsts/21.fst toUpper.fst |\
printstrings -p -m $DIR//data/chars.syms -n 5

#draw
file=lm.char.2
fstdraw --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/chars.syms  ${file}.fst  ${file}.dot
dot -Tjpg  ${file}.dot >  ${file}.jpg

#3.2 Estimating Character-Based Language Models
#We use the KenLM Toolkit to build a bigram character-based language model:
$DIR/tools/kenlm/bin/lmplz -o 2 < $DIR/data/train/train.chars > lm.char.2.arpa

#3.3 Building WFSAs from ARPA Language Models
#We use the Kaldi Toolkit to build a WFSA (an acceptor) from the character bigram language model
LD_LIBRARY_PATH=$DIR/tools/kaldi/tools/openfst/lib/ \
$DIR/tools/kaldi/src/lmbin/arpa2fst \
--read-symbol-table=$DIR/data/chars.syms lm.char.2.arpa - | fstarcsort - > lm.char.2.fst
fstinfo lm.char.2.fst | head

#3.4  Weighted Transduction from Uncased to Mixed-Case Character Sequences
#Here we compose the casing WFST toUpper.fst with the character-based language model lm.char.2.fst
fstdeterminize lm.char.2.fst | fstminimize | fstarcsort | fstcompose toUpper.fst - > toUpper.lm.char.2.fst

#3.5  Generating Recased Hypotheses
#We can apply the weighted transducer to the original lowercased character string and print the best hypothesis under the language model
fstcompose $DIR/data/ptb/ptb-dev.input.fsts/21.fst toUpper.lm.char.2.fst |\
fstproject --project_output | fstshortestpath |\
printstrings -m $DIR//data/chars.syms -w

#3.5.1  Generating the 1-Best WFSAs
#We process the entire 1700 sentence dev set in batch mode. The following step generates 1700 WFSAs with the best-scoring mixed case character sequence for each sentence.
mkdir hyps.lm.char.2
for id in `seq 1 1700`; do
	fstcompose $DIR/data/ptb/ptb-dev.input.fsts/${id}.fst toUpper.lm.char.2.fst | fstproject --project_output | fstshortestpath > hyps.lm.char.2/${id}.fst
done

#3.5.2  Generating Character Sequence Hypotheses
#printstrings has a --range option that processes WFSAs in succession by replacing the ? symbol in the --input argument by an index in the range. 
printstrings --range=1:1700 --input=hyps.lm.char.2/?.fst -m $DIR/data/chars.syms \
--output=hyps.lm.char.2/rawhyps
# look at the output file, to make sure it's sensible
awk 'NR==1' hyps.lm.char.2/rawhyps

#3.5.3  Remove the Sentence Start and Sentence End Symbols
sed 's,<s>,,;s,</s>,,' hyps.lm.char.2/rawhyps > hyps.lm.char.2/chyps
# look at the output, to make sure it
awk 'NR==21' hyps.lm.char.2/chyps

#3.5.4  Generating Word Sequence Hypotheses
sed 's, ,,g;s,_, ,g' hyps.lm.char.2/chyps > hyps.lm.char.2/whyps
awk 'NR==21' hyps.lm.char.2/whyps

#3.6  Evaluation
#3.6.1  Performance at the Character Level
#Score the character output against the character references:
python $DIR/scripts/eval_recasing.py --test hyps.lm.char.2/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

#To get a sentence-by-sentence analysis of the comparison, add the --v
python $DIR/scripts/eval_recasing.py --test hyps.lm.char.2/hyps \
--ref $DIR/data/ptb/ptb-dev.chars -v | head -5

#3.6.2  Performance at the Word Level
python $DIR/scripts/eval_recasing.py --test hyps.lm.char.2/whyps \
--ref $DIR/data/ptb/ptb-dev.words

#3.7  Questions
#Question 1. The operation fstcompose 21.fst toUpper.fst yields a transducer. Describe the input language and the output language of this transducer.
fstcompose $DIR/data/ptb/ptb-dev.input.fsts/21.fst toUpper.fst 21ToUpper.fst

#Question 2. The operation fstcompose 21.fst toUpper.lm.char.2.fst also yields a transducer.
fstcompose $DIR/data/ptb/ptb-dev.input.fsts/21.fst toUpper.lm.char.2.fst 21UpperLM.fst

#4 Recasing with Word-based N-Gram Language Models
#4.1  Word to Character Transducer OpenFST provides the makelex.py script for creating such transducers that map a word to its spelling. 
egrep -v -e\< $DIR/data/words.syms |\
python $DIR/scripts/makelex.py | tee c2w.txt |\
fstcompile --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/words.syms \
--keep_isymbols --keep_osymbols |\
fstrmepsilon | fstdeterminize | fstminimize > c2w.fst

#create the transducer for the word ‘he’ :
egrep -v -e\< $DIR/data/words.syms | grep -i -w he |\
python $DIR/scripts/makelex.py |\
fstcompile --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/words.syms \
--keep_isymbols --keep_osymbols |\
fstrmepsilon | fstdeterminize | fstminimize > he.c2w.fst

#FST that inserts a punctuation symbol (or deletes a punctuation symbol
awk '$2>2 && $2<37 {print 0,1,$1,"<eps>"}END{print 1}' $DIR/data/chars.syms |\
fstcompile --osymbols=$DIR/data/words.syms --isymbols=$DIR/data/chars.syms \
--keep_isymbols --keep_osymbols  > punc.fst

head  $DIR/data/chars.syms |\
awk '$2>2 && $2<37 {print 0,1,$1,"<eps>"}END{print 1}'  |\
fstcompile --osymbols=$DIR/data/words.syms --isymbols=$DIR/data/chars.syms \
--keep_isymbols --keep_osymbols  > tinypunc.fst

#4.3 Unknown Word Transducer
fstcompile --keep_isymbols --keep_osymbols --osymbols=$DIR/data/chars.syms \
--isymbols=$DIR/data/words.syms $DIR/common/unk.txt | fstinvert > unk.fst

#4.3.1  Words and Unknown Words
fstunion c2w.fst unk.fst > c2w+unk.fst

#4.4 Character Sequence to Word Sequence Transducer
fstcompile --acceptor --isymbols=$DIR/data/chars.syms  \
--keep_isymbols  $DIR/common/SentenceSkeleton.txt  > SentenceSkeleton.fst
fstreplace --epsilon_on_replace=true SentenceSkeleton.fst 999999990 \
punc.fst 999999991 c2w+unk.fst 999999992  | fstarcsort > cseq2wseq.fst


#4.5  Applying the Character Sequence to Word Sequence Transducer
printstrings -m $DIR/data/chars.syms --input $DIR/data/ptb/ptb-dev.input.fsts/21.fst

#The cseq2wseq.fst transducer is applied as follows:
mkdir -p cseq2wseq/
fstcompose $DIR/data/ptb/ptb-dev.input.fsts/21.fst toUpper.fst |\
fstproject --project_output |  fstcompose - cseq2wseq.fst > cseq2wseq/21.fst
printstrings -m $DIR/data/chars.syms  -n 5 -u < cseq2wseq/21.fst

fstproject --project_output 21ToUpperTrunc.fst 21output.fst
fstcompose 21output.fst cseq2wseq.fst   21output2wseq.fst
fstcompose  21ToUpperTrunc.fst cseq2wseq.fst  21output2wseqnoproject.fst

#Build transducers to map mixed-cased character sequences to mixed-case word sequences for the sentences in the development set:
mkdir -p cseq2wseq/
for id in `seq 1 1700`; do
fstcompose $DIR/data/ptb/ptb-dev.input.fsts/$id.fst toUpper.fst |\
fstproject --project_output | fstcompose - cseq2wseq.fst > cseq2wseq/$id.fst
done

#testing c2w and unk
fstunion he.c2w.fst unk.fst heunk.fst

#4.6  Word-level Language Models
#We generate the training data for the word-based LM by replacing punctuation symbols in the training text with whitespace:
sed -f $DIR/scripts/puncstrip.sed $DIR/data/train/train.words > lm.word.train.txt
awk 'NR==4' $DIR/data/train/train.words
awk 'NR==4' lm.word.train.txt

#A  word-based  unigram  LM  is  built  
$DIR/tools/kenlm/bin/lmplz -o 1 <lm.word.train.txt > lm.word.1.arpa
LD_LIBRARY_PATH=$DIR/tools/kaldi/tools/openfst/lib/ \
$DIR/tools/kaldi/src/lmbin/arpa2fst \
--read-symbol-table=$DIR/data/words.syms lm.word.1.arpa lm.word.1.fst

#4.7  Applying the Word-based Language Model
fstcompose cseq2wseq/21.fst lm.word.1.fst | printstrings -w -m $DIR/data/chars.syms -n 5 -u
fstcompose cseq2wseq/21.fst lm.word.1.fst |\
printstrings -w -m $DIR/data/words.syms -n 5 -u -p

#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p hyps.lm.words.1
for id in `seq 1 1700`; do
fstcompose cseq2wseq/$id.fst lm.word.1.fst | fstshortestpath > hyps.lm.words.1/$id.fst
done
# Generate and score the mixed-case character sequences
printstrings --range=1:1700 --input=hyps.lm.words.1/?.fst -m $DIR/data/chars.syms \
--output=hyps.lm.words.1/rawhyps
sed 's,<s>,,;s,</s>,,'   hyps.lm.words.1/rawhyps > hyps.lm.words.1/chyps
python $DIR/scripts/eval_recasing.py --test hyps.lm.words.1/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  hyps.lm.words.1/chyps > hyps.lm.words.1/whyps
python $DIR/scripts/eval_recasing.py --test hyps.lm.words.1/whyps \
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


