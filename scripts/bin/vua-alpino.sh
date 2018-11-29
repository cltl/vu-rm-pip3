#!/bin/bash
#
# component: vua-alpino
#----------------------------------------------------

usage() {
  echo "Usage: $0 [ -t TIME_OUT ]" 1>&2
  exit 1
}
time_out=0
while getopts ":t:" opt; do
  case "$opt" in
    t)
      time_out=$OPTARG ;;
    *)
      usage ;;
  esac
done
shift $((OPTIND - 1))

workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
modulesdir=$workdir/components/python
source $workdir/.newsreader
cd $modulesdir/morphosyntactic_parser_nl

if [ "$time_out" -ne 0 ]; then
  python -m alpinonaf -t $time_out
else 
  python -m alpinonaf
fi 
