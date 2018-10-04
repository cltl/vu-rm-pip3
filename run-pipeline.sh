#!/bin/bash
#
# Script for running the pipeline wrapper
# This script produces output files in the directory from which 
# it is called.
# -----------------------------------------------
wrapper_dir=/home/arnoult/vu-rm-pip3
# you can copy this config file and adapt it as you wish 
#cfg=$wrapper_dir/example/pipeline.yml 
log=$(pwd)/pipeline.log
usage() {
  echo "Usage: $0 [ -c CFG ] [ -l LOGFILE ] [ -i IN_LAYERS ] [ -o GOAL_LAYERS ] [ -m GOAL_MODULES ]" 1>&2
  exit 1
}

while getopts ":c:l:i:o:m:" opt; do
  case "$opt" in
    c)
      cfg=$OPTARG ;;
    l)
      log=$OPTARG ;;
    i)
      in_layers=$OPTARG ;;
    o)
      out_layers=$OPTARG ;;
    m)
      with_modules=$OPTARG ;;
    *)
      usage ;;
  esac
done
shift $((OPTIND - 1))

#args="-c $cfg -d $wrapper_dir/scripts/bin/ -l $log "
args="-l $log "
if [ ! -z $cfg ]; then
  args="$args -c $cfg"
fi
if [ ! -z $in_layers ]; then
  args="$args -i $in_layers"
fi
if [ ! -z $out_layers ]; then
  args="$args -o $out_layers"
fi
if [ ! -z $with_modules ]; then
  args="$args -m $with_modules"
fi

cd $wrapper_dir
python -m wrapper $args
