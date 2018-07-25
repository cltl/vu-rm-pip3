#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
export jarsdir=$workdir/target
export modulesdir=$workdir/modules
export scriptdir=$workdir/scripts/install
export envvars=${workdir}/.newsreader
for dir in $jarsdir $modulesdir 
do
  [[ ! -d $dir ]] && mkdir -p $dir
done
touch $envvars

function install-tok {
  echo "Installing tokenizer ..."
  $scriptdir/package-from-git.sh ixa-ehu/ixa-pipe-tok 56f83ce package 1.8.0 
  echo "Finished installing the tokenizer."
}

function install-mor {
  echo "Installing the parser ..."
  $scriptdir/get-tar.sh http://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/Alpino-x86_64-Linux-glibc-2.19-21235-sicstus.tar.gz 
  echo "export ALPINO_HOME=${modulesdir}/Alpino" >> $envvars
  source $envvars
  $scriptdir/get-from-git.sh cltl/morphosyntactic_parser_nl 6f789bd 
  echo "Finished installing the parser."
}

function install-nerc {
  echo "Installing the NERC module ..."
  $scriptdir/get-tar.sh http://ixa2.si.ehu.es/ixa-pipes/models/ixa-pipes-1.1.1.tar.gz
  echo "Finished installing NERC."
}

function install-wsd {
  echo "Installing the WSD module ..."
  $scriptdir/install-from-git.sh cltl/svm_wsd 0300439 install_naf.sh
  echo "Finished installing WSD ..."
}

function install-ned {
  echo "Installing NED module and dbpedia resources ..."
  mkdir $modulesdir/spotlight
  cd $workdir/resources
  mvn install:install-file -Dfile=dbpedia-spotlight-0.7.jar -DgroupId=ixa -DartifactId=dbpedia-spotlight -Dversion=0.7 -Dpackaging=jar -DgeneratePom=true 
  cd $modulesdir/spotlight
  wget http://sourceforge.net/projects/dbpedia-spotlight/files/2016-04/nl/model/nl.tar.gz
  tar -zxvf nl.tar.gz
  wget http://ixa2.si.ehu.es/ixa-pipes/models/wikipedia-db.tar.gz
  tar -xzvf wikipedia-db.tar.gz
  rm *tar.gz
  
  $scriptdir/package-from-git.sh ixa-ehu/ixa-pipe-ned 062a983 package 1.1.6
  echo "Finished installing NED module."
}

function install-heideltime {
  echo "Installing time normalization ..."
  $scriptdir/install-heideltime.sh ixa-ehu/ixa-heideltime 2229a00
  echo "Finished installing time normalization."
}

function install-onto {
  echo "Installing OntoTagger..."
  $scriptdir/package-from-git.sh cltl/OntoTagger c3796c5 install ontotagger-v3.1.1-jar-with-dependencies
  echo "Finished installing OntoTagger."
}

function install-vua-resources {
  echo "Installing vua resources..." 
  $scriptdir/get-from-git.sh cltl/vua-resources e730ce6
  echo "Finished installing vua resources."
}

function install-srl {
  echo "Installing SRL (Sonar)..."
  $scriptdir/get-from-git.sh newsreader/vua-srl-nl 675d22d 
  echo "Finished installing srl module."
}

function install-dutch-nominal-events {
  echo "Installing Dutch nominal event labeller..."
  $scriptdir/get-from-git.sh newsreader/vua-srl-dutch-nominal-events 6115b31 
  echo "Finished installing Dutch nominal event labeller."
}

function install-multi-factuality {
  echo "Installing factuality module..."
  $scriptdir/get-from-git.sh cltl/multilingual_factuality cbad484
  echo "Finished installing factuality module."
}

function install-opinmin {
  echo "Installing opinion miner..."
  $scriptdir/install-from-git.sh rubenIzquierdo/opinion_miner_deluxePP 40a714c $scriptdir/opin-install.sh
  for lang in de en es fr it
  do
    rm -rf $modulesdir/opinion_miner_deluxePP/models/models*${lang}*
  done
  echo "Finished installing opinion miner."
}

function install-evcoref {
  echo "Installing event coreference module..."
  $scriptdir/package-from-git.sh cltl/EventCoreference 95cfbf5 install v3.1.2-jar-with-dependencies 
  echo "Finished installing event coreference module."
}
install-tok
install-mor
install-nerc
install-wsd
install-ned
install-heideltime
install-onto
install-vua-resources
install-srl
install-dutch-nominal-events
install-multi-factuality
install-opinmin
install-evcoref

echo "Finished."
