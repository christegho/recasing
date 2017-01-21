################################################################
###Evaluate Bigrams - Done
################################################################
mkdir -p hyps.lm.words.2
for id in `seq 1 1700`; do
fstcompose cseq2wseq/$id.fst lm.word.2.fst | fstshortestpath > hyps.lm.words.2/$id.fst
done
# Generate and score the mixed-case character sequences
printstrings --range=1:1700 --input=hyps.lm.words.2/?.fst -m $DIR/data/chars.syms \
--output=hyps.lm.words.2/rawhyps
sed 's,<s>,,;s,</s>,,'   hyps.lm.words.2/rawhyps > hyps.lm.words.2/chyps
python $DIR/scripts/eval_recasing.py --test hyps.lm.words.2/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  hyps.lm.words.2/chyps > hyps.lm.words.2/whyps
python $DIR/scripts/eval_recasing.py --test hyps.lm.words.2/whyps \
--ref $DIR/data/ptb/ptb-dev.words

################################################################
###Evaluate Trigrams #Done
################################################################
mkdir -p hyps.lm.words.3
for id in `seq 1 1700`; do
fstcompose cseq2wseq/$id.fst lm.word.3.fst | fstshortestpath > hyps.lm.words.3/$id.fst
done
#Done
# Generate and score the mixed-case character sequences
printstrings --range=1:1700 --input=hyps.lm.words.3/?.fst -m $DIR/data/chars.syms \
--output=hyps.lm.words.3/rawhyps
sed 's,<s>,,;s,</s>,,'   hyps.lm.words.3/rawhyps > hyps.lm.words.3/chyps
python $DIR/scripts/eval_recasing.py --test hyps.lm.words.3/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  hyps.lm.words.3/chyps > hyps.lm.words.3/whyps
python $DIR/scripts/eval_recasing.py --test hyps.lm.words.3/whyps \
--ref $DIR/data/ptb/ptb-dev.words

################################################################
###Evaluate Bigrams -  KFTT 
################################################################

mkdir -p kftt.hyps.lm.words.2
for id in `seq 1 1113`; do
fstcompose kfttcseq2wseq/$id.fst lm.word.2.fst | fstshortestpath > kftt.hyps.lm.words.2/$id.fst
done

# Generate and score the mixed-case character sequences
printstrings --range=1:1113 --input=kftt.hyps.lm.words.2/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lm.words.2/rawhyps
sed 's,<s>,,;s,</s>,,'   kftt.hyps.lm.words.2/rawhyps > kftt.hyps.lm.words.2/chyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.words.2/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  kftt.hyps.lm.words.2/chyps > kftt.hyps.lm.words.2/whyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.words.2/whyps \
--ref $DIR/data/kftt/kftt-dev.words

################################################################
###Evaluate Trigrams KFTT 
################################################################
mkdir -p kftt.hyps.lm.words.3
for id in `seq 1 1113`; do
fstcompose kfttcseq2wseq/$id.fst lm.word.3.fst | fstshortestpath > kftt.hyps.lm.words.3/$id.fst
done

# Generate and score the mixed-case character sequences
printstrings --range=1:1113 --input=kftt.hyps.lm.words.3/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lm.words.1/rawhyps
sed 's,<s>,,;s,</s>,,'   kftt.hyps.lm.words.1/rawhyps > kftt.hyps.lm.words.3/chyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.words.3/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  kftt.hyps.lm.words.3/chyps > kftt.hyps.lm.words.3/whyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.words.3/whyps \
--ref $DIR/data/kftt/kftt-dev.words


#################################################################################
#2-char 3-word evaluation KFTT 
#################################################################################
#IP
mkdir -p kftt.lats.lm.word.3
for id in `seq 1 1113`; do
fstcompose kfttcseq2wseq/$id.fst lm.word.3.fst | fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > kftt.lats.lm.word.3/$id.fst
done


#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p kftt.hyps.lats.lm.words.3
mkdir -p kftt.hyps.lats.lm.charwords.3
for id in `seq 1 1113`; do
#fstcompose cseq2wseq/$id.fst lats.lm.word.1/$id.fst | fstshortestpath > hyps.lats.lm.words.1/$id.fst
#fstcompose lats.lm.char.2/$id.fst cseq2wseq/$id.fst > hyps.lats.lm.charwords.1/$id.fst
fstcompose kftt.hyps.lats.lm.charwords.1/$id.fst kftt.lats.lm.word.3/$id.fst  > kftt.hyps.lats.lm.words.3/$id.fst
done


# Generate and score the mixed-case character sequences
printstrings --range=1:1113 --input=kftt.hyps.lats.lm.words.3/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lats.lm.words.3/rawhyps
sed 's,<s>,,;s,</s>,,'  kftt.hyps.lats.lm.words.3/rawhyps > kftt.hyps.lats.lm.words.3/chyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.3/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  kftt.hyps.lats.lm.words.3/chyps > kftt.hyps.lats.lm.words.3/whyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.3/whyps \
--ref $DIR/data/kftt/kftt-dev.words

#################################################################################
# Generate 4-gram Word model
#################################################################################
$DIR/tools/kenlm/bin/lmplz -o 4 < $DIR/data/train/train.words > lm.word.4.arpa
head -20 lm.word.4.arpa
LD_LIBRARY_PATH=$DIR/tools/kaldi/tools/openfst/lib/ \
$DIR/tools/kaldi/src/lmbin/arpa2fst \
--read-symbol-table=$DIR/data/words.syms lm.word.4.arpa - |\
fstarcsort - > lm.word.4.fst


fstinfo lm.word.4.fst | head

mkdir -p lats.lm.word.4
for id in `seq 1 1700`; do
fstcompose cseq2wseq/$id.fst lm.word.4.fst | fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > lats.lm.word.4/$id.fst
done

#Test with 21.fst
fstcompose cseq2wseq/21.fst lats.lm.word.4/21.fst |\
printstrings -w -m $DIR/data/words.syms  -n 5 -u -p
<s> We Re about to see if advertising works </s> 	62.6475
<s> We Re about to see if advertising Works </s> 	64.8174
<s> We about to see if advertising works </s> 	64.9121
<s> We Re about to see if Advertising works </s> 	64.9346
<s> we Re about to see if advertising works </s> 	66.2705

################################################################
###Evaluate 4grams #
################################################################
mkdir -p hyps.lm.words.4
for id in `seq 1 1700`; do
fstcompose cseq2wseq/$id.fst lm.word.4.fst | fstshortestpath > hyps.lm.words.4/$id.fst
done
#
# Generate and score the mixed-case character sequences
printstrings --range=1:1700 --input=hyps.lm.words.4/?.fst -m $DIR/data/chars.syms \
--output=hyps.lm.words.4/rawhyps
sed 's,<s>,,;s,</s>,,'   hyps.lm.words.4/rawhyps > hyps.lm.words.4/chyps
python $DIR/scripts/eval_recasing.py --test hyps.lm.words.4/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  hyps.lm.words.4/chyps > hyps.lm.words.4/whyps
python $DIR/scripts/eval_recasing.py --test hyps.lm.words.4/whyps \
--ref $DIR/data/ptb/ptb-dev.words

################################################################
###Evaluate 4grams -  KFTT  
################################################################

mkdir -p kftt.hyps.lm.words.4
for id in `seq 1 1113`; do
fstcompose kfttcseq2wseq/$id.fst lm.word.4.fst | fstshortestpath > kftt.hyps.lm.words.4/$id.fst
done
#
# Generate and score the mixed-case character sequences
printstrings --range=1:1113 --input=kftt.hyps.lm.words.4/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lm.words.4/rawhyps
sed 's,<s>,,;s,</s>,,'   kftt.hyps.lm.words.4/rawhyps > kftt.hyps.lm.words.4/chyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.words.4/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  kftt.hyps.lm.words.4/chyps > kftt.hyps.lm.words.4/whyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.words.4/whyps \
--ref $DIR/data/kftt/kftt-dev.words

#################################################################################
#2-char 4-word evaluation 
#################################################################################
#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p hyps.lats.lm.words.4
mkdir -p hyps.lats.lm.charwords.4
for id in `seq 1 1700`; do

#fstcompose lats.lm.char.2/$id.fst cseq2wseq/$id.fst > hyps.lats.lm.charwords.1/$id.fst
fstcompose hyps.lats.lm.charwords.1/$id.fst lats.lm.word.4/$id.fst  > hyps.lats.lm.words.4/$id.fst
done


# Generate and score the mixed-case character sequences
printstrings --range=1:1700 --input=hyps.lats.lm.words.4/?.fst -m $DIR/data/chars.syms \
--output=hyps.lats.lm.words.4/rawhyps
sed 's,<s>,,;s,</s>,,'  hyps.lats.lm.words.3/rawhyps > hyps.lats.lm.words.4/chyps
python $DIR/scripts/eval_recasing.py --test hyps.lats.lm.words.4/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  hyps.lats.lm.words.4/chyps > hyps.lats.lm.words.4/whyps
python $DIR/scripts/eval_recasing.py --test hyps.lats.lm.words.4/whyps \
--ref $DIR/data/ptb/ptb-dev.words


###################################################################
3-char
####################################################################
#3.2 Estimating Character-Based Language Models
#We use the KenLM Toolkit to build a bigram character-based language model:
$DIR/tools/kenlm/bin/lmplz -o 3 < $DIR/data/train/train.chars > lm.char.3.arpa

#3.3 Building WFSAs from ARPA Language Models
#We use the Kaldi Toolkit to build a WFSA (an acceptor) from the character bigram language model
LD_LIBRARY_PATH=$DIR/tools/kaldi/tools/openfst/lib/ \
$DIR/tools/kaldi/src/lmbin/arpa2fst \
--read-symbol-table=$DIR/data/chars.syms lm.char.3.arpa - | fstarcsort - > lm.char.3.fst
fstinfo lm.char.3.fst | head

#3.4  Weighted Transduction from Uncased to Mixed-Case Character Sequences
#Here we compose the casing WFST toUpper.fst with the character-based language model lm.char.2.fst
fstdeterminize lm.char.3.fst | fstminimize | fstarcsort | fstcompose toUpper.fst - > toUpper.lm.char.3.fst


#3.5.1  Generating the 1-Best WFSAs
#We process the entire 1700 sentence dev set in batch mode. The following step generates 1700 WFSAs with the best-scoring mixed case character sequence for each sentence.
mkdir hyps.lm.char.3
for id in `seq 1 1700`; do
	fstcompose $DIR/data/ptb/ptb-dev.input.fsts/${id}.fst toUpper.lm.char.3.fst | fstproject --project_output | fstshortestpath > hyps.lm.char.3/${id}.fst
done

mkdir kftt.hyps.lm.char.3
for id in `seq 1 1113`; do
	fstcompose $DIR/data/kftt/kftt-dev.input.fsts/${id}.fst toUpper.lm.char.3.fst | fstproject --project_output | fstshortestpath > kftt.hyps.lm.char.3/${id}.fst
done

#3.5.2  Generating Character Sequence Hypotheses
#printstrings has a --range option that processes WFSAs in succession by replacing the ? symbol in the --input argument by an index in the range. 
printstrings --range=1:1700 --input=hyps.lm.char.3/?.fst -m $DIR/data/chars.syms \
--output=hyps.lm.char.3/rawhyps
# look at the output file, to make sure it's sensible
awk 'NR==1' hyps.lm.char.3/rawhyps

#3.5.3  Remove the Sentence Start and Sentence End Symbols
sed 's,<s>,,;s,</s>,,' hyps.lm.char.3/rawhyps > hyps.lm.char.3/chyps
# look at the output, to make sure it
awk 'NR==21' hyps.lm.char.3/chyps

#3.5.4  Generating Word Sequence Hypotheses
sed 's, ,,g;s,_, ,g' hyps.lm.char.3/chyps > hyps.lm.char.3/whyps
awk 'NR==21' hyps.lm.char.3/whyps

#3.6  Evaluation
#3.6.1  Performance at the Character Level
#Score the character output against the character references:
python $DIR/scripts/eval_recasing.py --test hyps.lm.char.3/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

#3.6.2  Performance at the Word Level
python $DIR/scripts/eval_recasing.py --test hyps.lm.char.3/whyps \
--ref $DIR/data/ptb/ptb-dev.words


#3.5.2  Generating Character Sequence Hypotheses
#printstrings has a --range option that processes WFSAs in succession by replacing the ? symbol in the --input argument by an index in the range. 
printstrings --range=1:1113 --input=kftt.hyps.lm.char.3/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lm.char.3/rawhyps


#3.5.3  Remove the Sentence Start and Sentence End Symbols
sed 's,<s>,,;s,</s>,,' kftt.hyps.lm.char.3/rawhyps > kftt.hyps.lm.char.3/chyps

#3.5.4  Generating Word Sequence Hypotheses
sed 's, ,,g;s,_, ,g' kftt.hyps.lm.char.3/chyps > kftt.hyps.lm.char.3/whyps


#3.6  Evaluation
#3.6.1  Performance at the Character Level
#Score the character output against the character references:
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.char.3/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

#3.6.2  Performance at the Word Level
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lm.char.3/whyps \
--ref $DIR/data/kftt/kftt-dev.words

#################################################################################
#2-char 4-word evaluation KFTT 
#################################################################################
mkdir -p kftt.lats.lm.word.4
for id in `seq 1 1113`; do
fstcompose kfttcseq2wseq/$id.fst lm.word.4.fst | fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > kftt.lats.lm.word.4/$id.fst
done


#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p kftt.hyps.lats.lm.words.4
mkdir -p kftt.hyps.lats.lm.charwords.4
for id in `seq 1 1113`; do
#fstcompose cseq2wseq/$id.fst lats.lm.word.1/$id.fst | fstshortestpath > hyps.lats.lm.words.1/$id.fst
#fstcompose lats.lm.char.2/$id.fst cseq2wseq/$id.fst > hyps.lats.lm.charwords.1/$id.fst
fstcompose kftt.hyps.lats.lm.charwords.1/$id.fst kftt.lats.lm.word.4/$id.fst  > kftt.hyps.lats.lm.words.4/$id.fst
done


# Generate and score the mixed-case character sequences
printstrings --range=1:1113 --input=kftt.hyps.lats.lm.words.4/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lats.lm.words.4/rawhyps
sed 's,<s>,,;s,</s>,,'  kftt.hyps.lats.lm.words.4/rawhyps > kftt.hyps.lats.lm.words.4/chyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.4/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  kftt.hyps.lats.lm.words.4/chyps > kftt.hyps.lats.lm.words.4/whyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.4/whyps \
--ref $DIR/data/kftt/kftt-dev.words


#################################################################################
#3-char 3-word evaluation KFTT 
#################################################################################
mkdir -p lats.lm.char.3
for id in `seq 1 1700`; do
fstcompose $DIR/data/ptb/ptb-dev.input.fsts/$id.fst toUpper.lm.char.3.fst |\
fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > lats.lm.char.3/$id.fst
done

mkdir -p kftt.lats.lm.char.3
for id in `seq 1 1113`; do
fstcompose $DIR/data/kftt/kftt-dev.input.fsts/$id.fst toUpper.lm.char.3.fst |\
fstproject --project_output |\
fstrmepsilon | fstdeterminize | fstminimize | fstarcsort > kftt.lats.lm.char.3/$id.fst
done

#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p kftt.hyps.lats.lm.words.33
mkdir -p kftt.hyps.lats.lm.charwords.33
for id in `seq 1 1113`; do
#fstcompose cseq2wseq/$id.fst lats.lm.word.1/$id.fst | fstshortestpath > hyps.lats.lm.words.1/$id.fst
fstcompose kftt.lats.lm.char.3/$id.fst kfttcseq2wseq/$id.fst > kftt.hyps.lats.lm.charwords.33/$id.fst
fstcompose kftt.hyps.lats.lm.charwords.33/$id.fst kftt.lats.lm.word.3/$id.fst  > kftt.hyps.lats.lm.words.33/$id.fst
done


# Generate and score the mixed-case character sequences
printstrings --range=1:1113 --input=kftt.hyps.lats.lm.words.33/?.fst -m $DIR/data/chars.syms \
--output=kftt.hyps.lats.lm.words.33/rawhyps
sed 's,<s>,,;s,</s>,,'  kftt.hyps.lats.lm.words.33/rawhyps > kftt.hyps.lats.lm.words.33/chyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.33/chyps \
--ref $DIR/data/kftt/kftt-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  kftt.hyps.lats.lm.words.33/chyps > kftt.hyps.lats.lm.words.33/whyps
python $DIR/scripts/eval_recasing.py --test kftt.hyps.lats.lm.words.33/whyps \
--ref $DIR/data/kftt/kftt-dev.words


#################################################################################
#3-char 3-word evaluation KFTT #TODO
#################################################################################
#Batch processing of the dev set follows the procedure for the character-based LM:
mkdir -p hyps.lats.lm.words.33
mkdir -p hyps.lats.lm.charwords.33
for id in `seq 1 1700`; do
#fstcompose cseq2wseq/$id.fst lats.lm.word.1/$id.fst | fstshortestpath > hyps.lats.lm.words.1/$id.fst
fstcompose lats.lm.char.3/$id.fst cseq2wseq/$id.fst > hyps.lats.lm.charwords.33/$id.fst
fstcompose hyps.lats.lm.charwords.33/$id.fst lats.lm.word.3/$id.fst  > hyps.lats.lm.words.33/$id.fst
done


# Generate and score the mixed-case character sequences
printstrings --range=1:1700 --input=hyps.lats.lm.words.33/?.fst -m $DIR/data/chars.syms \
--output=hyps.lats.lm.words.33/rawhyps
sed 's,<s>,,;s,</s>,,'  hyps.lats.lm.words.33/rawhyps > hyps.lats.lm.words.33/chyps
python $DIR/scripts/eval_recasing.py --test hyps.lats.lm.words.33/chyps \
--ref $DIR/data/ptb/ptb-dev.chars

# Generate and score the mixed-case word sequences
sed 's, ,,g;s,_, ,g'  hyps.lats.lm.words.33/chyps > hyps.lats.lm.words.33/whyps
python $DIR/scripts/eval_recasing.py --test hyps.lats.lm.words.33/whyps \
--ref $DIR/data/ptb/ptb-dev.words


