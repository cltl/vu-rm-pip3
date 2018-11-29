#!/bin/sh
#
# Docker pipeline run script:
#   - defines a few modes of operations on the pipeline
#     (full or partial pipeline)
#   - sets a few pipeline component options  
#     (alpino time out, opinion models) 
#   - calls the base pipeline script with the right arguments
#  
#--------------------------------------------------------


usage() {
  echo "Usage: $0 [ -m <all|opinions|srL> ] [ -t ALPINO_TIME_OUT ] [ -o OPINION_DATA <news|hotel|hotelnews> ] [ -n NO_SRL_NOMINAL_EVENTS ] input.txt" 1>&2
  exit 1
}

# mode 'all' runs the full pipeline; 
# mode 'opinions' runs: tokenizer, alpino parser, NERC and Opinions modules
# mode 'srl' runs modules needed for SRL layer
mode="all"

# 0 -> no time limit
alpino_time_out=0

# choice is between
opinion_data="news"

# 1 -> SRL for verbal and nominal predicates; 0 -> nominal predicates only
nominal_events=1

opinion_opt=0
srl_opt=0

while getopts ":m:t:o:n" opt; do
  case "$opt" in
    m)
      mode=$OPTARG ;;
    t)
      alpino_time_out=$OPTARG ;;
    o)
      opinion_data=$OPTARG 
      opinion_opt=1 ;;
    n)
      nominal_events=0 
      srl_opt=1 ;;
    *)
      usage ;;
  esac
done
shift $((OPTIND - 1))

# checking option compatibility
if [ "$mode" = "opinions" ] && [ "$srl_opt" -eq 1 ]; then
  echo "WARNING: srl option \'n\' has no effect in opinion mode"
fi
if [ "$mode" = "srl" ] && [ "$opinion_opt" -eq 1 ]; then  
  echo "WARNING: opinion option \'o\' has no effect in srl mode"
fi

# optional arguments to pipeline run script
optstring=""
if [ "$mode" = "opinions" ]; then
  optstring="$optstring -o opinions"
elif [ "$mode" = "srl" ]; then
  if [ "$nominal_events" -eq 0 ]; then
    optstring="$optstring -m vua-framenet-classifier"
  else
    optstring="$optstring -o srl"
  fi
fi

substr=""
if [ "$alpino_time_out" -ne 0 ]; then
  substr="${substr}vua-alpino:-t ${alpino_time_out};"
fi
if [ "$mode" != "srl" ]; then
  substr="${substr}opinion-miner:-d ${opinion_data};"
fi  
if [ -n "$substr" ]; then
  optstring="${optstring} -s \"${substr%%;}\"" 
fi


cat $1 | bash ./run-pipeline.sh $optstring
>&2 cat pipeline.log
