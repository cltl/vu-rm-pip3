#!/bin/bash
#
# component: vua-eventcoreference
#----------------------------------------------------

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/resources
jarsdir=$VURM_LIB/java
jarfile=$jarsdir/EventCoreference-v3.1.2-jar-with-dependencies.jar
lang_resource="odwn_orbn_gwg-LMF_1.3.xml.gz"
java_module=eu.newsreader.eventcoreference.naf.EventCorefWordnetSim
java_options="--method leacock-chodorow"
java_options="$java_options  --wn-lmf $modulesdir/vua-resources/$lang_resource"
java_options="$java_options  --sim 2.0"
java_options="$java_options  --wsd 0.8"
java_options="$java_options  --relations XPOS_NEAR_SYNONYM#HAS_HYPERONYM#HAS_XPOS_HYPERONYM#event"
  
java -Xmx812m -cp $jarfile $java_module $java_options
