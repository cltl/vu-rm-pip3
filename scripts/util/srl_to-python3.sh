#!/bin/bash
#
# converts python 2 to python2/3-compatible code, using:
#   - 2to3
#   - futurize (make sure it is installed first)
#   - module-specific changes
#----------------------------------------------------------
usage() {                                        
  echo "Usage: $0 [ -m MODULE_DIR ]" 1>&2 
  exit 1                                         
}

while getopts ":m:" opt; do
  case "${opt}" in
    m)
      modulesdir=${OPTARG} ;;
    *)
      usage ;;
  esac
done
shift "$(($OPTIND -1))"


dy3=$modulesdir/vua-srl-nl
py3=$dy3/nafAlpinoToSRLFeatures.py


fix_double_bkts() {
  for f in $1/*.py
  do
    sed -i "s:print((\(.*\))):print(\1):" $f
  done
}

call_py23() {
  d=$1
  2to3 -wn $d/*.py
  futurize --stage1 -wn $d/*.py
  fix_double_bkts $d
}

fix_indent() {
  sed -i "s:^ [ ]*\t:\t:" $1
}

fix_str() {
  for f in $1/*.py
  do
    sed -i "s:.encode('utf-8')::" $f
    sed -i "s:.decode('utf-8')::" $f
  done
}

fix_srl() {
  call_py23 $dy3
  fix_str $dy3
  fix_indent $py3
}

fix_srl
