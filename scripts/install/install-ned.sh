#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

usage() {
  echo "Usage: $0 github_sfx commit_nb target_dir util_dir" 1>&2
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
util_dir=$4

module=$(basename ${github_sfx})

# clone and package / install module ------------
cd $scratch
git clone https://github.com/${github_sfx}.git
cd $module
git checkout $commit_nb
$util_dir/fix-surefire-plugin.sh pom.xml
mvn clean package
mv target/*.jar $target_dir


