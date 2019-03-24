#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

usage() {
  echo "Usage: $0 github_sfx commit_nb target_dir" 1>&2
  exit 1
}

if [ $# -ne 3 ]; then
  usage
fi

github_sfx=$1
commit_nb=$2
target_dir=$3
#------------------------------------------------

mkdir $target_dir
# get module ------------
cd $scratch
echo "cloning https://github.com/${github_sfx}.git"
git clone https://github.com/${github_sfx}.git
cd $(basename ${github_sfx})
git checkout $commit_nb

mv Grammatical-words.nl $target_dir
mv *odwn*gz $target_dir
mv nl-luIndex.xml $target_dir
# for naf2sem-grasp
for f in ili.ttl.gz mapping_eurovoc_skos.label.concept.gz source.txt
do
  mv $f $target_dir
done
