#!/bin/bash
#
# component: vua-wsd
#----------------------------------------------------

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/lib/python
python $modulesdir/svm_wsd/dsc_wsd_tagger.py --naf -ref odwnSY
