#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [ $# -ne 4 ]; then
  echo "USAGE: $0 github_sfx commit_nb target_dir resources_dir 1>&2 "
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
util_dir=$5
module=$(basename ${github_sfx})


# clone and package / install module ------------

cd $scratch
echo "cloning https://github.com/${github_sfx}.git"
git clone https://github.com/${github_sfx}.git
cd $module
git checkout $commit_nb

echo "building vuheideltimewrapper..."
$util_dir/fix-surefire-plugin.sh pom.xml
mvn clean install
mv target/*with-dependencies.jar $target_dir

echo "copying resources..." 
wdir=$resources_dir/$module
mkdir -p $wdir
mv lib/alpino-to-treetagger.csv $wdir
mv conf/config.props $wdir
