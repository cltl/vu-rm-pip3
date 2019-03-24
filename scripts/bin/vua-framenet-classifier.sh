#!/bin/bash
#
# component: vua-framenet-classifier
#----------------------------------------------------

  
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
jarsdir=$VURM_LIB/java
java -Xmx1812m -cp "$jarsdir/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 | gawk '/^frameMap.size()/ {next}; {print}'

