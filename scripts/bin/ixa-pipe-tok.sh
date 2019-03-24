#!/bin/bash
#
# component: ixa-pipe-tok
#----------------------------------------------------
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)

source $workdir/.newsreader
jarfile=$VURM_LIB/java/ixa-pipe-tok-1.8.5-exec.jar
java -Xmx1000m -jar $jarfile tok -l nl --inputkaf
  
