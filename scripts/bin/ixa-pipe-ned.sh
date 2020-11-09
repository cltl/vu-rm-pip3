#!/bin/bash
#
# component: ixa-pipe-ned
#----------------------------------------------------

PORT=2020
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/java
resourcesdir=$VURM_LIB/resources
scriptsdir=${workdir}/scripts
cd $workdir
$scriptsdir/util/connect-dbpedia-spotlight.sh $resourcesdir/spotlight $PORT
java -jar $modulesdir/ixa-pipe-ned-1.1.6.jar -p $PORT -i $resourcesdir/spotlight/wikipedia-db -n nlEn
