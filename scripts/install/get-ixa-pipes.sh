#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

usage() {
  echo "Usage: $0 version target_dir resources_dir" 1>&2
  exit 1
}

if [ $# -ne 3 ]; then
  usage
fi

version=$1
target_dir=$2
resourcesdir=$3

#------------------------------------------------

mkdir $resourcesdir/nerc-models
# get and package module ------------
cd $scratch

wget http://ixa2.si.ehu.es/ixa-pipes/models/ixa-pipes-${version}.tar.gz 
tar -zxvf ixa-pipes-${version}.tar.gz
mv ixa-pipes-${version}/*nerc*.jar $target_dir
mv ixa-pipes-${version}/*tok*.jar $target_dir
mv ixa-pipes-${version}/nerc-models*/nl/*.bin $resourcesdir/nerc-models/
