#!/bin/bash
#
# modified version of the install_me.sh script of the opinion-miner module
# uses publicly available models 

usage() {
  echo "Usage: $0 github_sfx commit_nb targetdir" 1>&2
  exit 1
}

if [ $# -ne 3 ]; then
  usage
fi

#------------------------------------------------
scriptdir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

github_sfx=$1
commit_nb=$2
targetdir=$3
module=$(basename ${github_sfx})

$scriptdir/get-from-git.sh $github_sfx $commit_nb $targetdir
cd $targetdir/$module

#Install CRF++
cd crf_lib
tar xvzf CRF++-0.58.tar.gz
cd CRF++-0.58
./configure
make
CRF_PATH=`pwd`
cd ..
cd ..
echo "PATH_TO_CRF_TEST='$CRF_PATH/crf_test'" > path_crf.py
echo 


#Install SVM_LIGHT
mkdir svm_light
cd svm_light
wget http://download.joachims.org/svm_light/current/svm_light.tar.gz
gunzip -c svm_light.tar.gz | tar xvf -
make
rm svm_light.tar.gz
cd ..


##Download the models
echo Downloading the trained models
mkdir models
cd models
wget http://kyoto.let.vu.nl/~izquierdo/public/models_opinion_miner_deluxePP/hotel/models_hotel_nl.tgz
wget http://kyoto.let.vu.nl/~izquierdo/public/models_opinion_miner_deluxePP/news/models_news_nl.tgz
wget http://kyoto.let.vu.nl/~izquierdo/public/models_opinion_miner_deluxePP/model_nl_hotel_news.tgz
tar xvzf models_hotel_nl.tgz
tar xvzf models_news_nl.tgz
tar xvzf model_nl_hotel_news.tgz
mv model_nl_hotel_news models_hotelnews_nl
cd ..

wget http://kyoto.let.vu.nl/~izquierdo/public/polarity_models.tgz
tar xvzf polarity_models.tgz
rm polarity_models.tgz

echo "All done"
