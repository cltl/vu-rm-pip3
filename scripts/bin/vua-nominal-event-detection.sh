#!/bin/bash
#
# component: vua-nominal-event-detection
#----------------------------------------------------
  
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
jarsdir=$VURM_LIB/java
vua_res=$VURM_LIB/resources/vua-resources
java -Xmx812m -cp "$jarsdir/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "$vua_res/nl-luIndex.xml" 

