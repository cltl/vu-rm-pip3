#!/bin/bash
#
# component: vua-ontotagging
#----------------------------------------------------

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
jarsdir=$VURM_LIB/java
vua_res=$VURM_LIB/resources/vua-resources
java -Xmx1812m -cp "$jarsdir/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "$vua_res/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "$vua_res/Grammatical-words.nl"

