#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

usage() {
  echo "Usage: $0 distrib_url target_dir util_dir" 1>&2
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
distrib=$1
target_dir=$2
util_dir=$3

name=$(basename ${distrib})
version=${name%%.tar.gz}
vid=${version#*v}

# get and package module ------------
cd $scratch

wget $distrib
tar -zxvf $name
cd *$vid
$util_dir/fix-surefire-plugin.sh pom.xml
mvn clean package
mv target/*jar-with-dependencies* $target_dir
