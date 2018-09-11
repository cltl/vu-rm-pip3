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

cd $targetdir
tar -xzvf ${scratch}/${module} 
