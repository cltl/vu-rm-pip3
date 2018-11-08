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

scriptdir=$workdir/scripts/util

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
$scriptdir/fix-surefire-plugin.sh pom.xml
mvn -U clean install
mv target/*.jar $javadir

echo "copying resources..." 
wdir=$resourcesdir/$module
mkdir -p $wdir
mv lib/jvntextpro-2.0.jar $wdir
mv lib/alpino-to-treetagger.csv $wdir
git clone https://github.com/HeidelTime/heideltime.git
cp heideltime/conf/config.props $wdir
