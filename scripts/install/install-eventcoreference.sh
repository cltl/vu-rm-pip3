#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

usage() {
  echo "Usage: $0 github_sfx commit_nb target_dir resources_dir" 1>&2
  exit 1
}

if [ $# -ne 4 ]; then
  usage
fi

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

#------------------------------------------------
github_sfx=$1
commit_nb=$2
target_dir=$3
resources_dir=$4
name=$(basename ${github_sfx})

# get and package module ------------
cd $scratch
git clone https://github.com/$github_sfx
cd $name
git checkout $commit_nb
mvn clean package
mv target/*jar-with-dependencies* $target_dir

if [ ! -d $resources_dir ]; then
  mkdir -p $resources_dir
fi
mv scripts/jena-log4j.properties $resources_dir
