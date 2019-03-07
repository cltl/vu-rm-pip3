#!/bin/bash
#
# component: vua-srl-dutch-nominal-events
#----------------------------------------------------
  
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/lib/python
python $modulesdir/vua-srl-dutch-nominal-events/vua-srl-dutch-additional-roles.py
