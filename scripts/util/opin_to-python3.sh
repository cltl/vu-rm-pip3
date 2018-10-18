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


dy4=$modulesdir/opinion_miner_deluxePP
py4a=$dy4/extract_features_target.py
py4b=$dy4/extract_sequences.py
py4c=$dy4/tag_file.py
py4d=$dy4/extract_features_expression.py

fix_double_bkts() {
  for f in $1/*.py
  do
    sed -i "s:print((\(.*\))):print(\1):" $f
  done
}

call_py23() {
  d=$1
  echo "-- Calling 2to3..."
  2to3 -wn $d/*.py
  echo "-- Calling futurize..."
  futurize --stage1 -wn $d/*.py
  fix_double_bkts $d
}

fix_argparse_1() {
  sed -i "s:\(.*\) = argparse.ArgumentParser(\(.*\), version='\(.*\)'):\1 = argparse.ArgumentParser(\2)\n\1.add_argument('--version', action='version', version='%(prog)s \3'):" $1
}

fix_argparse_2() {
  sed -i "s:\(.*\) = argparse.ArgumentParser(\(.*\), version=\(.*\), \(.*\)):\1 = argparse.ArgumentParser(\2, \4)\n\1.add_argument('--version', action='version', version='%(prog)s \3'):" $1
}

fix_argparse() {
  for f in $1/*.py
  do
    fix_argparse_2 $f
    fix_argparse_1 $f
  done
}

fix_float_2() {
  sed -i "s:dist/3:dist//3:" $1
}

fix_str() {
  for f in $1/*.py
  do
    sed -i "s:.encode('utf-8')::" $f
    sed -i "s:.decode('utf-8')::" $f
  done
}

fix_encoding() {
  for f in $1/*.py
  do
    perl -0777 -i -pe "s/( *)(.*)'r'\)\n(.*)pickler.load\((.*)\)/\1\2'rb'\)\n\1try:\n    \3pickler.load\(\4,encoding='bytes'\)\n\1except TypeError:\n    \3pickler.load\(\4\)/" $f
  done
}

fix_decode() {
  sed -i "s:line = line.strip()$:line = line.strip().decode():" $1
}

fix_none_comp() {
  sed -i "s:numseq1 > numseq2:numseq1 is not None and numseq2 is not None and int(numseq1) > int(numseq2):" $1
}

# makes python3 converted code python2 compatible again
back_to2() {
  for f in $1/*.py
  do 
    awk '/import/ && !x {print "from __future__ import print_function"; x=1} 1' $f > $f.tmp
    mv $f.tmp $f
  done
}

fix_opin() {
  call_py23 $dy4
  echo "module-specific fixes"
  fix_encoding $dy4
  fix_argparse $dy4
  fix_str $dy4
  fix_float_2 $py4a
  fix_decode $py4b
  fix_none_comp $py4b
  back_to2 $dy4
}

fix_opin




