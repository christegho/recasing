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
file=toUpper
fstdraw --isymbols=$DIR/data/chars.syms --osymbols=$DIR/data/chars.syms  ${file}.fst  ${file}.dot
dot -Tjpg  ${file}.dot >  ${file}.jpg


