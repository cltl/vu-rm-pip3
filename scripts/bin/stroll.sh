#!/bin/bash
#
# component: stanza
#----------------------------------------------------

usage() {
  echo "Usage: $0 " 1>&2
  exit 1
}


workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/python
cd $modulesdir/stroll

python run_srl.py --model models/srl.pt --naf
