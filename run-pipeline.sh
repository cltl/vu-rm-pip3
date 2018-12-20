#!/bin/bash
#
# Script for running the pipeline wrapper
# This script produces output files in the directory from which 
# it is called.
# -----------------------------------------------
wrapper_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
# you can copy this config file and adapt it as you wish: 
#cfg=$wrapper_dir/example/pipeline.yml 
log=$(pwd)/pipeline.log
usage() {
  echo "Usage: $0 [ -c CFG ] [ -d BIN_DIR ] [ -l LOGFILE ] [ -i IN_LAYERS ] [ -o GOAL_LAYERS ] [ -m GOAL_MODULES ] [ -s MODULE_OPTS ]" 1>&2
  exit 1
}

while getopts ":c:d:l:i:o:m:s:" opt; do
  case "$opt" in
    c)
      cfg=$OPTARG ;;
    d)
      bindir=$OPTARG ;;
    l)
      log=$OPTARG ;;
    i)
      in_layers=$OPTARG ;;
    o)
      out_layers=$OPTARG ;;
    m)
      with_modules=$OPTARG ;;
    s)
      substr=$OPTARG ;;
    *)
      usage ;;
  esac
done
shift $((OPTIND - 1))

args="-l $log "
if [ ! -z $cfg ]; then
  args="$args-c $cfg "
fi
if [ ! -z $bindir ]; then
  args="$args-d $bindir "
fi
if [ ! -z $in_layers ]; then
  args="$args-i $in_layers "
fi
if [ ! -z $out_layers ]; then
  args="$args-o $out_layers "
fi
if [ ! -z $with_modules ]; then
  args="$args-m $with_modules "
fi
if [ ! -z $substr ]; then
  args="$args-s $substr "
fi

>&2 echo "calling pipeline wrapper with args: $args"
cd $wrapper_dir
python -m wrapper $args

