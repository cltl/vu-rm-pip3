#!/bin/bash
#
# - backup python2-only modules
# - converts these modules to python2/3-compatible code
# 
#----------------------------------------------------------
set -e

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/components/python
modulesdir2=$workdir/components/python2-only
mkdir $modulesdir2

dy1=svm_wsd
dy2=vua-srl-nl
dy3=opinion_miner_deluxePP
for d in $dy1 $dy2 $dy3 
do
  cp -r $modulesdir/$d $modulesdir2/$d
done

$workdir/scripts/util/to-python3.sh -m $modulesdir 
