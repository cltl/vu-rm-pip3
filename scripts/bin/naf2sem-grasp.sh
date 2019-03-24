#!/bin/bash
#
# RDF extraction
#---------------------------
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
RESOURCES=$VURM_LIB/resources/vua-resources
LIB=$VURM_LIB/java
if [ ! -L jena-log4j.properties ]; then
  ln -s $VURM_LIB/resources/naf2sem/jena-log4j.properties jena-log4j.properties
fi

java -Xmx2000m -cp "$LIB/EventCoreference-v3.1.2-jar-with-dependencies.jar" eu.newsreader.eventcoreference.naf.GetSemFromNafStream --non-entities --project test --all --ili "$RESOURCES/ili.ttl.gz" --perspective --eurovoc-en "$RESOURCES/mapping_eurovoc_skos.label.concept.gz" --source-frames "$RESOURCES/source.txt"
