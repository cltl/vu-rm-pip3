#!/bin/bash
#
# Tests each module on a reference NAF input, and checks 
# its output against the corresponding reference NAF output.
# 
#---------------------------------------------------------- 
IFS=$'\n\t'

usage() {                                        
  echo "Usage: $0 [ -v VERBOSE ]" 1>&2 
  exit 1                                         
}

while getopts ":vp" opt; do
  case "${opt}" in
    v)
      verbose=1 ;;
    *)
      usage ;;
  esac
done
shift "$(($OPTIND -1))"

#------ variables and setup ---------------------------------

export workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd .. && pwd)
export jarsdir=$workdir/target
export modulesdir=$workdir/modules
export scriptdir=$workdir/scripts/util
export resourcesdir=$workdir/resources
export naflang=nl

envvars=$workdir/.newsreader
source $envvars

refdir=$workdir/test/ref
testdir=$workdir/test/out
[[ -d $testdir ]] && rm -rf $testdir
mkdir $testdir

infile=$testdir/test.raw.naf
cp $refdir/test.raw.naf $infile
pfx=test
outfile=$testdir/${pfx}.out.naf

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

succeeded=0
failed=0
check_against_ref () {
  lref=$(cat ${refdir}/${pfx}.$1.naf | wc -l)
  lout=$(cat ${testdir}/${pfx}.$1.naf | wc -l)
  if [ "$lref" -ne "$lout" ]; then
    echo "$1: failed; expected to produce file of length $lref, but found $lout."
    failed=$((failed + 1))
  else
    echo "$1: ok"
    succeeded=$((succeeded + 1))
  fi
}

run () {
  msg=$1
  id=$2
  module=$3
  $module < ${refdir}/${pfx}.${id}.naf > ${testdir}/${pfx}.${module}.naf 2>>$log
  check_against_ref $module
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

#---- main ------------------------------------------------
run_modules

if [ "$succeeded" -eq 14 ]; then
  cp ${testdir}/${pfx}.corf.naf $outfile
  layers=$(grep -c "<linguisticProcessors" $outfile || true)
  if [ "$layers" -ne 10 ]; then
    echo "expected 10 layers, but found $layers"
  fi
  lps=$(grep -c "<lp" $outfile || true)
  if [ "$lps" -ne 16 ]; then
    echo "expected 16 processors, but found $lps"
  fi
  lps=$(grep -c "<lp" $outfile || true)
  echo "All tests passed."
else
  echo "Tests: $succeeded succeeded, $failed failed"
fi
