#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

#------------------------------------------------

mkdir $resourcesdir/ixa-pipes
# get and package module ------------
cd $scratch

wget http://ixa2.si.ehu.es/ixa-pipes/models/ixa-pipes-1.1.1.tar.gz 
tar -zxvf ixa-pipes-1.1.1.tar.gz
mv ixa-pipes-1.1.1/*nerc*.jar $javadir
mv ixa-pipes-1.1.1/*tok*.jar $javadir
mv ixa-pipes-1.1.1/nerc-models* $resourcesdir/ixa-pipes
