#!/bin/bash
set -eo pipefail
IFS=$'\n\t'


workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
export modulesdir=$workdir/components
export resourcesdir=$modulesdir/resources
export javadir=$modulesdir/java
export pythondir=$modulesdir/python
export scriptdir=$workdir/scripts/install
export envvars=${workdir}/.newsreader
for dir in $pythondir $resourcesdir $javadir
do
  [[ ! -d $dir ]] && mkdir -p $dir
done
touch $envvars


function install-mor {
  echo "Installing the parser ..."
  $scriptdir/get-tar.sh http://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/Alpino-x86_64-Linux-glibc-2.19-21235-sicstus.tar.gz $resourcesdir
  echo "export ALPINO_HOME=${resourcesdir}/Alpino" >> $envvars
  source $envvars
  $scriptdir/get-from-git.sh cltl/morphosyntactic_parser_nl 6f789bd $pythondir 
  echo "Finished installing the parser."
}

function install-ixa-pipes {
  echo "Installing the ixa pipes (tok/nerc) ..."
  $scriptdir/get-ixa-pipes.sh
  echo "Finished installing the ixa pipes (tok/nerc)."
}

function install-wsd {
  echo "Installing the WSD module ..."
  $scriptdir/install-from-git.sh cltl/svm_wsd 0300439 install_naf.sh
  echo "Finished installing WSD ..."
}

function install-heideltime {
  echo "Installing time normalization ..."
  $scriptdir/install-heideltime.sh ixa-ehu/ixa-heideltime 2229a00
  echo "Finished installing time normalization."
}

function install-onto {
  echo "Installing OntoTagger..."
  $scriptdir/get-exec-jar-from-distrib.sh https://github.com/cltl/OntoTagger/archive/v3.1.1.tar.gz
  echo "Finished installing OntoTagger."
}

function install-vua-resources {
  echo "Installing vua resources..." 
  $scriptdir/get-from-git.sh cltl/vua-resources e730ce6 $resourcesdir
  echo "Finished installing vua resources."
}

function install-srl {
  echo "Installing SRL (Sonar)..."
  $scriptdir/get-from-git.sh newsreader/vua-srl-nl 675d22d $pythondir
  echo "Finished installing srl module."
}

function install-dutch-nominal-events {
  echo "Installing Dutch nominal event labeller..."
  $scriptdir/get-from-git.sh newsreader/vua-srl-dutch-nominal-events 6115b31 $pythondir
  echo "Finished installing Dutch nominal event labeller."
}

function install-multi-factuality {
  echo "Installing factuality module..."
  $scriptdir/get-from-git.sh cltl/multilingual_factuality cbad484 $pythondir
  echo "Finished installing factuality module."
}

function install-opinmin {
  echo "Installing opinion miner..."
  $scriptdir/install-from-git.sh rubenIzquierdo/opinion_miner_deluxePP 40a714c $scriptdir/opin-install.sh
  echo "Finished installing opinion miner."
}

function install-evcoref {
  echo "Installing event coreference module..."
  $scriptdir/get-exec-jar-from-distrib.sh https://github.com/cltl/EventCoreference/archive/v3.1.1.tar.gz
  echo "Finished installing event coreference module."
}

install-mor
install-ixa-pipes
install-wsd
install-heideltime
install-onto
install-vua-resources
install-srl
install-dutch-nominal-events
install-multi-factuality
install-opinmin
install-evcoref

echo "Finished."
