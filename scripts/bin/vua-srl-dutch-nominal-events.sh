#!/bin/bash
#
# component: vua-srl-dutch-nominal-events
#----------------------------------------------------
  
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/python
python $modulesdir/vua-srl-dutch-nominal-events/vua-srl-dutch-additional-roles.py
