#!/bin/bash
#
# Runs the newsreader pipeline on either:
# - a default example raw NAF
# - a user-specified raw NAF (option -i)
# The modules are called in a fixed order.
# The pipeline tests whether the number of annotation 
# layers (as found in the NAF header) increases after each 
# called module.
#----------------------------------------------------------
set -eo pipefail
IFS=$'\n\t'

export workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd .. && pwd)
infile=$workdir/test/example/test.raw.naf

usage() {                                        
  echo "Usage: $0 [ -v VERBOSE ] [ -i INPUT_FILE ]" 1>&2 
  exit 1                                         
}
while getopts ":vi:" opt; do
  case "${opt}" in
    v)
      verbose=1 ;;
    i)
      infile=${OPTARG};;
    *)
      usage ;;
  esac
done
shift "$(($OPTIND -1))"


#---- Variables and setup ---------------------------------
export jarsdir=$workdir/target
export modulesdir=$workdir/modules
export scriptdir=$workdir/scripts/util
envvars=$workdir/.newsreader
source $envvars

naflang=`cat $infile | $scriptdir/langdetect.py`
export naflang
if [ "$naflang" != "nl" ]; then
  echo "pipeline expects a Dutch input file, but detected language $naflang"
  exit 1
fi


testdir=$(dirname $infile)
pfx=${infile%%.raw.naf}
outfile=${pfx}.out.naf

if [ $verbose ]; then
  log=$testdir/test.log
  [[ -f $log ]] && rm $log 
  touch $log
else
  log=/dev/null
fi

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT


#---- Module definitions --------------------------------------

source $scriptdir/modules.sh

#---- Functions -----------------------------------------------

check_file() {
  in_file=${pfx}.$1.naf 
  out_file=${pfx}.$2.naf 
  size1=$(grep -c "<lp" $in_file || true)
  size2=$(grep -c "<lp" $out_file || true)
  added=$(($size2 - $size1))
  if [ $added -le 0 ]; then
    echo "ERROR: module $2 failure (went from $size1 processors/layers to $size2)"
    exit 1
  else
    echo "module $2 added annotations to $added layer(s)" 
  fi
}

run() {
  msg=$1
  id=$2
  module=$3
  $module < ${pfx}.${id}.naf > ${pfx}.${module}.naf 2>>$log
  check_file $id $module
}

run_modules () {
  run "tokenizer"	 		raw 	tok 
  run "tagging/lemmatization/parsing"	tok 	mor  
  run "named entity recognition" 	mor 	nerc  
  run "word sense disambiguation" 	nerc 	wsd  
  run "named entity disambiguation" 	wsd 	ned  
  run "time expressions"		ned 	time  
  run "predicate matrix tagging" 	time 	onto  
  run "SRL (Sonar)" 			onto 	srl  
  run "nominal event detection" 	srl 	nomev  
  run "nominal predicate SRL" 		nomev 	npsrl  
  run "FrameNet labelling" 		npsrl 	fnet  
  run "Factuality" 			fnet 	fact  
  run "Opinion miner" 			fact 	opin  
  run "Event coreference" 		opin 	corf  
}

#---- Main ------------------------------------------------
run_modules

cp ${pfx}.corf.naf $outfile
layers=$(grep -c "<linguisticProcessors" $outfile || true)
lps=$(grep -c "<lp" $outfile || true)
echo "Done. Outfile has $lps processors across $layers layers"
