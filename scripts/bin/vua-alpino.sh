#!/bin/bash
#
# component: vua-alpino
#----------------------------------------------------

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/components/python
source $workdir/.newsreader
cd $modulesdir/morphosyntactic_parser_nl
python -m alpinonaf -t 0.2 
  
