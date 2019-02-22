#!/bin/bash


############################################################
# Author:   Ruben Izquierdo Bevia ruben.izquierdobevia@vu.nl
# Version:  1.1
# Date:     3 Nov 2013
# 
# ------ Revision ------------------------------------------
# Author: Sophie Arnoult sophie.arnoult@posteo.net
# Version: 1.2
# Date: 19 Dec 2018
# Concerns: 
#   - removing installation of KafNafParserPy
#   - using publicly available models
#############################################################

usage() {
  echo "Usage: $0 github_sfx commit_nb targetdir" 1>&2
  exit 1
}

if [ $# -ne 3 ]; then
  usage
fi

set -e

#------------------------------------------------
scriptdir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
github_sfx=$1
commit_nb=$2
targetdir=$3
module=$(basename ${github_sfx})

$scriptdir/get-from-git.sh $github_sfx $commit_nb $targetdir
cd $targetdir/$module


echo 'Downloading and installing LIBSVM from https://github.com/cjlin1/libsvm'
mkdir lib
cd lib
wget --no-check-certificate  https://github.com/cjlin1/libsvm/archive/master.zip 2>/dev/null
zip_name=`ls -1 | head -1`
unzip $zip_name > /dev/null
rm $zip_name
folder_name=`ls -1 | head -1`
mv $folder_name libsvm
cd libsvm/python
make > /dev/null 2> /dev/null
echo LIBSVM installed correctly lib/libsvm

cd ../../..

echo 'Downloading models...(could take a while)'
wget kyoto.let.vu.nl/~izquierdo/public/models_wsd_svm_dsc.tgz 2> /dev/null
echo 'Unzipping models...'
tar xzf models_wsd_svm_dsc.tgz
rm models*tgz
echo 'Models installed in folder models'
