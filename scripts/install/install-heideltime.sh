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
cd $modulesdir
echo "cloning https://github.com/${github_sfx}.git"
git clone https://github.com/${github_sfx}.git
echo "checking out commit $commit_nb"
cd $module
git checkout $commit_nb

echo "$scratch" 
cd $scratch
echo "getting Heideltime props..." 
git clone https://github.com/HeidelTime/heideltime.git
cp heideltime/conf/config.props $modulesdir/$module

echo "getting jvntextpro..."
wget http://ixa2.si.ehu.es/~jibalari/jvntextpro-2.0.jar
mv jvntextpro-2.0.jar $modulesdir/$module/lib/

echo "getting install-to-project-repo"
git clone https://github.com/carchrae/install-to-project-repo.git
cp install-to-project-repo/install-to-project-repo.py $modulesdir/$module

cd $modulesdir/$module
python --version
python install-to-project-repo.py

mvn clean install
