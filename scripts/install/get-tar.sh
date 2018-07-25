#!/bin/bash

set -euo pipefail
IFS=$'\n\t' 

link=$1
module=$(basename $link)

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

cd $scratch
wget $link

cd $modulesdir
tar -xzvf ${scratch}/${module} 
