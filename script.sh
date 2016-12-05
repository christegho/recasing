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

#.5.1  Generating the 1-Best WFSAs
#We process the entire 1700 sentence dev set in batch mode. The following step generates 1700 WFSAs with the best-scoring mixed case character sequence for each sentence.
mkdir hyps.lm.char.2
for id in `seq 1 1700`; do
	fstcompose $DIR/data/ptb/ptb-dev.input.fsts/${id}.fst toUpper.lm.char.2.fst | fstproject --project_output | fstshortestpath > hyps.lm.char.2/${id}.fst
done

#draw
for file in toUpper lm.char.2
do
fstdraw --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/chars.syms  ${file}.fst  ${file}.dot
dot -Tjpg  ${file}.dot >  ${file}.jpg
done


