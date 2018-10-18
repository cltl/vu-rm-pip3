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


dy2=$modulesdir/svm_wsd
py2=$dy2/dsc_wsd_tagger.py

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

fix_argparse_1() {
  sed -i "s:\(.*\) = argparse.ArgumentParser(\(.*\), version='\(.*\)'):\1 = argparse.ArgumentParser(\2)\n\1.add_argument('--version', action='version', version='%(prog)s \3'):" $1
}

fix_float_1() {
  sed -i "s:)/3:)//3:" $1
}

fix_str() {
  for f in $1/*.py
  do
    sed -i "s:.encode('utf-8')::" $f
    sed -i "s:.decode('utf-8')::" $f
  done
}

# makes python3 converted code python2 compatible again
back_to2() {
  awk '/import/ && !x {print "from __future__ import print_function"; x=1} 1' $1 > $1.tmp
  mv $1.tmp $1
}

fix_wsd() {
  call_py23 $dy2
  fix_argparse_1 $py2
  fix_float_1 $py2
  fix_str $dy2
  back_to2 $py2
}

fix_wsd

