#!/bin/bash
#
# component: vua-ontotagging
#----------------------------------------------------

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/components/resources
jarsdir=$workdir/components/java
  
vua_res=$modulesdir/vua-resources
java -Xmx1812m -cp "$jarsdir/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "$vua_res/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "$vua_res/Grammatical-words.nl"

