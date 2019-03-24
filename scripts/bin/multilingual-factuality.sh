#!/bin/bash
#
# component: multilingual-factuality
#----------------------------------------------------

  
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/python
python $modulesdir/multilingual_factuality/feature_extractor/rule_based_factuality.py
