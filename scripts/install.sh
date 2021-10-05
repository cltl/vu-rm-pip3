#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

usage() {
  echo "Usage: $0 [ -c CLEAN ] [ -l LIBDIR ]" 1>&2
  exit 1
}

clean=0
while getopts ":cl:" opt; do
  case "$opt" in
    c)
      clean=1 ;;
    l) 
      libdir=$OPTARG ;;
    *)
      usage ;;
  esac
done
shift $((OPTIND - 1))

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd .. && pwd)

# sets libdir for components installation
if [ -z "$libdir" ]; then
  libdir=$workdir/lib
fi
# sets VURM_LIB to libdir for execution scripts
envvars=$workdir/.newsreader
echo "export VURM_LIB=$libdir" > $envvars
echo "export ALPINO_HOME=\$VURM_LIB/resources/Alpino" >> $envvars

cfgdir=$workdir/cfg
javadir=$libdir/java
resourcesdir=$libdir/resources
pythondir=$libdir/python
scriptdir=$workdir/scripts/install
utildir=$workdir/scripts/util

if [ "$clean" -eq 1 ] && [ -d $libdir ]; then
  echo "Removing $libdir for clean install"
  rm -rf $libdir
fi

for dir in $pythondir $javadir $resourcesdir
do
  [[ ! -d $dir ]] && mkdir -p $dir
done

# Loads component versions
source $cfgdir/component_versions

function install-text2naf {	
  echo "Installing text2naf module ..."
  $scriptdir/install-java-component.sh cltl/text2naf $v_text2naf $javadir
  echo "Finished installing text2naf."
}

function install-mor {
  echo "Installing the Alpino parser and wrapper ..."
  # $scriptdir/install-alpino.sh http://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/${v_alpino}.tar.gz $resourcesdir/Alpino
  $scriptdir/install-alpino.sh https://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/Alpino-x86_64-Linux-glibc-2.23-git388-sicstus.tar.gz $resourcesdir/Alpino
  $scriptdir/get-from-git.sh cltl/morphosyntactic_parser_nl $v_morphosyntactic_parser_nl $pythondir 
  echo "Finished installing the Alpino wrapper."
}

function install-ixa-pipes {
  echo "Installing the ixa-nerc models ..."
  $scriptdir/get-ixa-pipes.sh $v_ixa_pipes $javadir $resourcesdir
  echo "Finished installing the ixa-nerc models."
}

function install-ned {
  echo "Installing NED and dbpedia resources ..."
  wdir=$resourcesdir/spotlight
  mkdir $wdir
  cd $wdir
  wget http://sourceforge.net/projects/dbpedia-spotlight/files/2016-04/nl/model/nl.tar.gz
  tar -zxvf nl.tar.gz
  wget http://ixa2.si.ehu.es/ixa-pipes/models/wikipedia-db.tar.gz
  tar -xzvf wikipedia-db.tar.gz
  rm *tar.gz
  wget https://sourceforge.net/projects/dbpedia-spotlight/files/spotlight/dbpedia-spotlight-${v_dbpedia_spotlight}.jar
  mvn install:install-file -Dfile=dbpedia-spotlight-${v_dbpedia_spotlight}.jar -DgroupId=ixa -DartifactId=dbpedia-spotlight -Dversion=0.7 -Dpackaging=jar -DgeneratePom=true 
  $scriptdir/install-ned.sh ixa-ehu/ixa-pipe-ned $v_ixa_pipe_ned $javadir $utildir
  echo "Finished installing NED module."
}

function install-vua-resources {
  echo "Installing vua resources..." 
  $scriptdir/get-vua-resources.sh cltl/vua-resources $v_vua_resources $resourcesdir/vua-resources
  echo "Finished installing vua resources."
}

function install-wsd {
  echo "Installing the WSD module ..."
  $scriptdir/install-wsd.sh cltl/svm_wsd $v_svm_wsd $pythondir
  echo "Finished installing WSD"
}

function install-heideltime {
  echo "Installing time normalization ..."
  $scriptdir/install-vuheideltimewrapper.sh cltl/vuheideltimewrapper $v_vuheideltimewrapper $javadir $resourcesdir 
  echo "Finished installing time normalization."
}

function install-onto {
  echo "Installing OntoTagger..."
  $scriptdir/install-ontotagger.sh cltl/OntoTagger $v_ontotagger $javadir
  echo "Finished installing OntoTagger."
}

function install-srl {
  echo "Installing SRL (Sonar)..."
  $scriptdir/get-from-git.sh sarnoult/vua-srl-nl $v_vua_srl_nl $pythondir
  echo "Finished installing srl module"
}

function install-dutch-nominal-events {
  echo "Installing Dutch nominal event labeller..."
  $scriptdir/get-from-git.sh sarnoult/vua-srl-dutch-nominal-events $v_vua_srl_dutch_nominal_events $pythondir
  echo "Finished installing Dutch nominal event labeller."
}

function install-multi-factuality {
  echo "Installing factuality module..."
  $scriptdir/get-from-git.sh cltl/multilingual_factuality $v_multilingual_factuality $pythondir
  echo "Finished installing factuality module."
}

function install-opinmin {
  echo "Installing opinion miner..."
  $scriptdir/install-opinion-miner.sh rubenIzquierdo/opinion_miner_deluxePP $v_opinion_miner_deluxePP $pythondir
  echo "Finished installing opinion miner"
}

function install-evcoref {
  echo "Installing event coreference module..."
  $scriptdir/install-eventcoreference.sh cltl/EventCoreference $v_eventcoreference $javadir $resourcesdir/naf2sem
  echo "Finished installing event coreference module."
}

install-text2naf
install-mor
install-ixa-pipes
install-ned
install-vua-resources
install-wsd
install-heideltime
install-onto
install-srl
install-dutch-nominal-events
install-multi-factuality
install-opinmin
install-evcoref

sudo apt-get install timbl

echo "Finished."
