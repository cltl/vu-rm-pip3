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
distrib=$1
module=$2

name=$(basename ${distrib})
version=${name%%.tar.gz}
vid=${version#*v}

# get and package module ------------
cd $scratch

wget $distrib
tar -zxvf $name
cd *$vid
mvn clean package
mv target/*jar-with-dependencies* $javadir
