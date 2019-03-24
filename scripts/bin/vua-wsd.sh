#!/bin/bash
#
# component: vua-wsd
#----------------------------------------------------

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/python
python $modulesdir/svm_wsd/dsc_wsd_tagger.py --naf -ref odwnSY
