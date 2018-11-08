#!/bin/sh

usage() {
  echo "Usage: $0 [ -m <ALL|OPINIONS> ] input.txt" 1>&2
  exit 1
}

# mode 'ALL' runs the full pipeline; 
# mode 'OPINIONS' runs: tokenizer, alpino parser, NERC and Opinions modules
mode="ALL"

while getopts ":m:" opt; do
  case "$opt" in
    m)
      mode=$OPTARG ;;
    *)
      usage ;;
  esac
done
shift $((OPTIND - 1))

if [ "$mode" = "ALL" ]; then
  cat $1 | bash ./run-pipeline.sh
  >&2 cat pipeline.log
elif [ "$mode" = "OPINIONS" ]; then
  cat $1 | bash ./run-pipeline.sh -o opinions
  >&2 cat pipeline.log
else
  >&2 echo "$mode not recognized; valid modes are ALL and OPINIONS"
fi
