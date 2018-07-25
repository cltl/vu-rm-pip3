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

usage() {                                        
  echo "Usage: $0 < raw.naf" 1>&2 
  exit 1                                         
}
while getopts ":" opt; do
  case "${opt}" in
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


scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

infile=$scratch/pipeline.in
cat > $infile 

naflang=`cat $infile | $scriptdir/langdetect.py`
export naflang
if [ "$naflang" != "nl" ]; then
  echo "pipeline expects a Dutch input file, but detected language $naflang"
  exit 1
fi

#---- Module definitions --------------------------------------

source $scriptdir/modules.sh

#---- Main ------------------------------------------------
cat $infile | tok | mor | nerc | wsd | ned | time | onto | srl | \
  nomev | npsrl | fnet | fact | opin | corf
