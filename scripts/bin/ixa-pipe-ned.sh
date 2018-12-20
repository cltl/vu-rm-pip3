#!/bin/bash
#
# component: ixa-pipe-ned
#----------------------------------------------------

 
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/components/java
resourcesdir=${workdir}/components/resources
scriptsdir=${workdir}/scripts
cd $workdir
$scriptsdir/util/connect-dbpedia-spotlight.sh $resourcesdir/spotlight
java -jar $modulesdir/ixa-pipe-ned-1.1.6.jar -p 2060 -i $resourcesdir/spotlight/wikipedia-db -n nlEn
