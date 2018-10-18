#!/bin/bash
#
# component: opinion-miner
#----------------------------------------------------


workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/components/python
cd $modulesdir/opinion_miner_deluxePP
python tag_file.py -polarity -d news
cd $workdir
