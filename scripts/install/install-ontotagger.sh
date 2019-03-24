#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

usage() {
  echo "Usage: $0 github_sfx commit_nb target_dir" 1>&2
  exit 1
}

if [ $# -ne 3 ]; then
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
name=$(basename ${github_sfx})

# get and package module ------------
cd $scratch
git clone https://github.com/$github_sfx
cd $name
git checkout $commit_nb
mvn clean install
mv target/*jar-with-dependencies* $target_dir
