#!/bin/bash
#
# modified version of the install_me.sh script of the opinion-miner module
# adds password for the models 


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
