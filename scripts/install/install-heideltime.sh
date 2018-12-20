#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [ $# -ne 5 ]; then
  echo "USAGE: $0 github_sfx commit_nb target_dir util_dir resources_dir 1>&2 "
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
resources_dir=$5
module=$(basename ${github_sfx})


# clone and package / install module ------------

cd $scratch
echo "cloning https://github.com/${github_sfx}.git"
git clone https://github.com/${github_sfx}.git
cd $module
git checkout $commit_nb

echo "install to project repo"
wget http://ixa2.si.ehu.es/~jibalari/jvntextpro-2.0.jar
mv jvntextpro-2.0.jar lib
git clone https://github.com/carchrae/install-to-project-repo
cp install-to-project-repo/install-to-project-repo.py .
python install-to-project-repo.py

echo "building ixa-heideltime..."
$util_dir/fix-surefire-plugin.sh pom.xml
mvn -U clean install
mv target/*.jar $target_dir

echo "copying resources..." 
wdir=$resources_dir/$module
mkdir -p $wdir
mv lib/jvntextpro-2.0.jar $wdir
mv lib/alpino-to-treetagger.csv $wdir
git clone https://github.com/HeidelTime/heideltime.git
cp heideltime/conf/config.props $wdir
