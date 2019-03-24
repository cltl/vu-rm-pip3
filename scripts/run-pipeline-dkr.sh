#!/bin/sh
#
# Docker pipeline run script:
#   - defines a few modes of operations on the pipeline
#     (full or partial pipeline)
#   - sets a few pipeline component options  
#     (alpino time out, opinion models) 
#   - also allows to call the base pipeline script with its arguments
#  
#--------------------------------------------------------


usage() {
  echo "Usage: $0 [ -m <all|entities|opinions|srl> ] \ 
                  [ -t ALPINO_TIME_OUT ] \
                  [ -o OPINION_DATA <news|hotel|hotelnews> ] \
                  [ -n NO_SRL_NOMINAL_EVENTS ] \
                  [ -r CONVERT_NAF2RDF ] \
                  [ -w WRAPPER_ARGS ] input.txt" 1>&2
  exit 1
}

# mode 'all' runs the full pipeline; 
# mode 'opinions' runs: tokenizer, alpino parser, NERC and Opinions components
# mode 'entities' runs: tokenizer, alpino parser, NERC and NED components
# mode 'srl' runs: tokenizer, alpino parser, WSD, ontotagging, SRL, FrameNet labelling, and (if not specified otherwise) nominal-predicate SRL components
mode="all"

# 0 -> no time limit
alpino_time_out=""

# choice is between
opinion_data="news"

# 1 -> SRL for verbal and nominal predicates; 0 -> nominal predicates only
nominal_events=1

# Convert NAF to RDF
naf2rdf=0

# wrapper args. This allows to run the pipeline with all its arguments
# Note that this will rewrite all other arguments
wrapper_args=""

opinion_opt=0
srl_opt=0
other_opt=0

while getopts ":m:t:o:w:nr" opt; do
  case "$opt" in
    m)
      mode=$OPTARG 
      other_opt=1 ;;
    t)
      alpino_time_out=$OPTARG 
      other_opt=1 ;;
    o)
      opinion_data=$OPTARG 
      opinion_opt=1 
      other_opt=1 ;;
    n)
      nominal_events=0 
      srl_opt=1 
      other_opt=1 ;;
    r)
      naf2rdf=1 ;;
    w)
      wrapper_args=$OPTARG ;;
    *)
      usage ;;
  esac
done
shift $((OPTIND - 1))

# checking option compatibility
check_option_compatibility() {
  if [ "$mode" = "opinions" ] && [ "$srl_opt" -eq 1 ]; then
    >&2 echo "WARNING: srl option \'n\' has no effect in opinion mode"
  fi
  if [ "$mode" = "srl" ] && [ "$opinion_opt" -eq 1 ]; then  
    >&2 echo "WARNING: opinion option \'o\' has no effect in srl mode"
  fi
  if [ "$mode" = "entities" ] && [ "$opinion_opt" -eq 1 ]; then  
    >&2 echo "WARNING: opinion option \'o\' has no effect in entities mode"
  fi
  if [ "$mode" = "entities" ] && [ "$srl_opt" -eq 1 ]; then  
    >&2 echo "WARNING: srl option \'n\' has no effect in entities mode"
  fi
  if [ -n $wrapper_args ] && [ "$other_opt" -eq 1 ]; then
    >&2 echo "WARNING: mode and other arguments will be overwritten by the argument to \'w\'"
  fi
  if [ "$naf2rdf" -eq 1 ] && [ -n $wrapper_args ] || [ "$naf2rdf" -eq 1 ] && [ "$other_opt" -eq 1 ]; then
    >&2 echo "WARNING: pipeline options are ignored when running naf2rdf"
  fi 
}

# optional arguments to pipeline run script
make_optstring() {
  optstring=""
  if [ "$mode" = "opinions" ]; then
    optstring="$optstring-o opinions "
  elif [ "$mode" = "entities" ]; then
    optstring="$optstring-o entities "
  elif [ "$mode" = "srl" ]; then
    optstring="$optstring-o srl "
  fi
  if [ "$nominal_events" -eq 0 ]; then
    optstring="$optstring-e vua-nominal-event-detection,vua-srl-dutch-nominal-events "
  fi
  substr=""
  if [ -n "$alpino_time_out" ]; then
    substr="${substr}vua-alpino:-t:${alpino_time_out};"
  fi
  if [ "$mode" != "srl" ] && [ "$opinion_data" != "news" ] ; then
    substr="${substr}opinion-miner:-d:${opinion_data};"
  fi  
  if [ -n "$substr" ]; then
    optstring="${optstring}-s ${substr%%;}" 
  fi
  echo $optstring
}

if [ "$naf2rdf" -eq 1 ]; then
  cat $1 | bash ./scripts/bin/naf2sem-grasp.sh
elif [ -n "$wrapper_args" ]; then
  cat $1 | bash ./scripts/run-pipeline.sh $wrapper_args
  >&2 cat pipeline.log
else
  cat $1 | bash ./scripts/run-pipeline.sh $(make_optstring)
  >&2 cat pipeline.log
fi

# closing connection to spotlight server 
if lsof -Pi :2060 >/dev/null ; then
  kill $(lsof -Pi :2060 -t)
fi
