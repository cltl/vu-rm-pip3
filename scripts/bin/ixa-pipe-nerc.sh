#!/bin/bash
#
# component: ixa-pipe-nerc
#----------------------------------------------------

 
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/components/java
rdir=${workdir}/components/resources/ixa-pipes
jarfile=$modulesdir/ixa-pipe-nerc-1.6.1-exec.jar
nercmodel=$rdir/nerc-models-1.6.1/nl/nl-6-class-clusters-sonar.bin
java -Xmx1500m -jar $jarfile tag -m $nercmodel

