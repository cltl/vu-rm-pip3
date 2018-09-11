#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

usage() {
  echo "Usage: $0 github_sfx commit_nb mvn_cmd jar_sfx" 1>&2
  exit 1
}

#if [ $# -ne 1 ]; then
#  usage
#fi

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

#------------------------------------------------
export workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
github_sfx=$1
commit_nb=$2
#mvn_cmd=$3
#jar_sfx=$4  # the version number or the full name of the jar

module=$(basename ${github_sfx})


# clone and package / install module ------------
cd $scratch
git clone https://github.com/${github_sfx}.git
cd $module
git checkout $commit_nb
mvn clean package
mv target/*.jar $javadir


