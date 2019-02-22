#!/bin/bash

set -euo pipefail
IFS=$'\n\t' 

link=$1
targetdir=$2
module=$(basename $link)

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

cd $scratch
wget $link
tar -xzvf $module 

mkdir $targetdir

for d in Alpino/*
do
  if [ "$d" != "Treebank" ] && [ "$d" != "TreebankTools" ] && [ "$d" != "Tokenization" ] && [ "$d" != "Generation" ]; then
    mv $d $targetdir
  fi
done


#  for d in Treebank TreebankTools Tokenization Generation
#  do
#    rm -rf $resourcesdir/Alpino/$d
#  done
