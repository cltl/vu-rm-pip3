#!/bin/bash
#
# component: opinion-miner
#----------------------------------------------------

model_data='news'
usage() {
  echo "Usage: $0 [ -d MODEL ]" 1>&2
  exit 1
}
while getopts ":d:" opt; do
  case "$opt" in
    d)
      model_data=$OPTARG ;;
    *)
      usage ;;
  esac
done
shift $((OPTIND - 1))

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
source $workdir/.newsreader
modulesdir=$VURM_LIB/python
cd $modulesdir/opinion_miner_deluxePP
python tag_file.py -polarity -d $model_data
cd $workdir
