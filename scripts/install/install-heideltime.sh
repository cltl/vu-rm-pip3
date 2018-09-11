#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [ $# -ne 2 ]; then
  echo "USAGE: $0 github_sfx commit_nb"
fi

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

#------------------------------------------------
github_sfx=$1
commit_nb=$2

module=$(basename ${github_sfx})


# clone and package / install module ------------
# set up module dir
wdir=$resourcesdir/$module
mkdir -p $wdir

cd $scratch
echo "cloning https://github.com/${github_sfx}.git"
git clone https://github.com/${github_sfx}.git
echo "checking out commit $commit_nb"
cd $module
git checkout $commit_nb
mvn clean package
mv target/*.jar $javadir
mv lib/alpino-to-treetagger.csv $wdir
echo "getting Heideltime props..." 
git clone https://github.com/HeidelTime/heideltime.git
cp heideltime/conf/config.props $wdir

echo "getting jvntextpro..."
wget http://ixa2.si.ehu.es/~jibalari/jvntextpro-2.0.jar
mv jvntextpro-2.0.jar $wdir

