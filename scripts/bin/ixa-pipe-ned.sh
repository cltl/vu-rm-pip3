#!/bin/bash
#
# component: ixa-pipe-ned
#----------------------------------------------------

 
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/java
resourcesdir=$VURM_LIB/resources
scriptsdir=${workdir}/scripts
cd $workdir
$scriptsdir/util/connect-dbpedia-spotlight.sh $resourcesdir/spotlight
java -jar $modulesdir/ixa-pipe-ned-1.1.6.jar -p 2010 -i $resourcesdir/spotlight/wikipedia-db -n nlEn
