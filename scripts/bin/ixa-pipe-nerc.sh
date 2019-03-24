#!/bin/bash
#
# component: ixa-pipe-nerc
#----------------------------------------------------

 
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/java
rdir=$VURM_LIB/resources
jarfile=$modulesdir/ixa-pipe-nerc-1.6.1-exec.jar
nercmodel=$rdir/nerc-models/nl-6-class-clusters-sonar.bin
java -Xmx1500m -jar $jarfile tag -m $nercmodel

