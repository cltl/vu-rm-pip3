#!/bin/bash
#
# component: vuheideltimewrapper
#----------------------------------------------------

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/lib/java
resdir=$workdir/lib/resources/vuheideltimewrapper
java -Xmx2000m -cp $modulesdir/vu-heideltime-wrapper-1.0-jar-with-dependencies.jar  vu.cltl.vuheideltimewrapper.CLI --stream --mapping $resdir/alpino-to-treetagger.csv --config $resdir/config.props --no-time-check
cd $workdir
