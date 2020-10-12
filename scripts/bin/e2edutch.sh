#!/bin/bash
#
# component: e2edutch
#----------------------------------------------------

usage() {
  echo "Usage: $0 " 1>&2
  exit 1
}

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/python
cd $modulesdir/e2e-Dutch

INPUTFILE=$scratch/inputfile.naf
cat > $INPUTFILE
python scripts/predict.py -f naf final $INPUTFILE
