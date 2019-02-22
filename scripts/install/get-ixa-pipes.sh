#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

usage() {
  echo "Usage: $0 target_dir resources_dir" 1>&2
  exit 1
}

if [ $# -ne 2 ]; then
  usage
fi

target_dir=$1
resourcesdir=$2
#------------------------------------------------

mkdir $resourcesdir/nerc-models
# get and package module ------------
cd $scratch

wget http://ixa2.si.ehu.es/ixa-pipes/models/ixa-pipes-1.1.1.tar.gz 
tar -zxvf ixa-pipes-1.1.1.tar.gz
mv ixa-pipes-1.1.1/*nerc*.jar $target_dir
mv ixa-pipes-1.1.1/*tok*.jar $target_dir
mv ixa-pipes-1.1.1/nerc-models*/nl/*.bin $resourcesdir/nerc-models/
