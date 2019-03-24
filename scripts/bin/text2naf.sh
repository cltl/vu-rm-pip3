#!/bin/bash
#
# component: text2naf
#----------------------------------------------------

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
jarsdir=$VURM_LIB/java
java -cp "$jarsdir/text2naf-1.0-SNAPSHOT-jar-with-dependencies.jar" createNafFromText --language nl --uri "http://www.newsreader-project.eu/example-news.html"

