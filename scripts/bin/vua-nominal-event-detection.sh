#!/bin/bash
#
# component: vua-nominal-event-detection
#----------------------------------------------------
  
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/components/resources
jarsdir=$workdir/components/java
vua_res=$modulesdir/vua-resources
java -Xmx812m -cp "$jarsdir/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "$vua_res/nl-luIndex.xml" 

