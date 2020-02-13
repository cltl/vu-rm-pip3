#!/bin/bash
#
# component: stanfordnlp
#----------------------------------------------------

usage() {
  echo "Usage: $0 " 1>&2
  exit 1
}


workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/python
cd $modulesdir/stanfordnlp_wrapper

python -m stanfordnlp_wrapper
