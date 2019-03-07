#!/bin/bash
#
# component: vua-srl
#----------------------------------------------------

set -e

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT
  
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/lib/python
mod=$modulesdir/vua-srl-nl
INPUTFILE=$scratch/inputfile
FEATUREVECTOR=$scratch/csvfile
TIMBLOUTPUTFILE=$scratch/timblpredictions
tee $INPUTFILE | python $mod/nafAlpinoToSRLFeatures.py > $FEATUREVECTOR
timbl -mO:I1,2,3,4 -i $mod/25Feb2015_e-mags_mags_press_newspapers.wgt -t $FEATUREVECTOR -o $TIMBLOUTPUTFILE &>/dev/null & wait
python $mod/timblToAlpinoNAF.py $INPUTFILE $TIMBLOUTPUTFILE
