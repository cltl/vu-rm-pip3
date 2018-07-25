#!/bin/bash
#
# Module calls 
#----------------------------------------------------

tok() {
  JARFILE=$jarsdir/ixa-pipe-tok-1.8.0.jar
  java -Xmx1000m -jar $JARFILE tok -l $naflang --inputkaf 
}
  
mor() {
  cd $modulesdir/morphosyntactic_parser_nl
  python -m alpinonaf -t 0.2 
}
  
nerc() {
  mdir=${modulesdir}/ixa-pipes-1.1.1
  jarfile=$mdir/ixa-pipe-nerc-1.6.1-exec.jar
  nercmodel=$mdir/nerc-models-1.6.1/nl/nl-6-class-clusters-sonar.bin
  java -Xmx1500m -jar $jarfile tag -m $nercmodel
}

ned() {
  spothostport=`$scriptdir/check_start_spotlight -l $naflang`
  export spotlighthost=`echo $spothostport | gawk -F ":" '{print $1}'`
  export spotlightport=`echo $spothostport | gawk -F":" '{print $2}'`
  echo "Spotlight server found on $spothostport." >&2
  if [ "$spotlighthost" == "none" ]; then
    echo "No Spotlight-server found."
    exit 5
  fi

  java -Xmx1000m -jar $jarsdir/ixa-pipe-ned-1.1.6.jar -p $spotlightport -i $modulesdir/spotlight/wikipedia-db -n nlEn
}

function time {
  cd $modulesdir/ixa-heideltime
  iconv -t utf-8//IGNORE | java -Xmx1000m -jar target/ixa.pipe.time.jar -m lib/alpino-to-treetagger.csv -c config.props
  cd $workdir
}
  
wsd() {
  python $modulesdir/svm_wsd/dsc_wsd_tagger.py --naf -ref odwnSY
}  
  
onto() {
  vua_res=$modulesdir/vua-resources
  java -Xmx1812m -cp "$jarsdir/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.KafPredicateMatrixTagger --mappings "fn;mcr;ili;eso" --key odwn-eq --version 1.2 --predicate-matrix "$vua_res/PredicateMatrix.v1.3.txt.role.odwn.gz" --grammatical-words "$vua_res/Grammatical-words.nl"
}
  
nomev() {
  vua_res=$modulesdir/vua-resources
  java -Xmx812m -cp "$jarsdir/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.NominalEventCoreference --framenet-lu "$vua_res/nl-luIndex.xml" 
}
  
npsrl() {
  python $modulesdir/vua-srl-dutch-nominal-events/vua-srl-dutch-additional-roles.py
}
  
srl() {
  mod=$modulesdir/vua-srl-nl
  INPUTFILE=$scratch/inputfile
  FEATUREVECTOR=$scratch/csvfile
  TIMBLOUTPUTFILE=$scratch/timblpredictions
  tee $INPUTFILE | python $mod/nafAlpinoToSRLFeatures.py > $FEATUREVECTOR
  timbl -mO:I1,2,3,4 -i $mod/25Feb2015_e-mags_mags_press_newspapers.wgt -t $FEATUREVECTOR -o $TIMBLOUTPUTFILE >/dev/null 2>/dev/null
  python $mod/timblToAlpinoNAF.py $INPUTFILE $TIMBLOUTPUTFILE
}
  
fnet() {
  java -Xmx1812m -cp "$jarsdir/ontotagger-v3.1.1-jar-with-dependencies.jar" eu.kyotoproject.main.SrlFrameNetTagger --frame-ns "fn:" --role-ns "fn-role:;pb-role:;fn-pb-role:;eso-role:" --ili-ns "mcr:ili" --sense-conf 0.05 --frame-conf 30 | gawk '/^frameMap.size()/ {next}; {print}'
}
  
fact() {
  python $modulesdir/multilingual_factuality/feature_extractor/rule_based_factuality.py
}
  
corf() {
  IFS=$' \n\t'
  jarfile=$jarsdir/EventCoreference-v3.1.2-jar-with-dependencies.jar
  lang_resource="odwn_orbn_gwg-LMF_1.3.xml.gz"
  java_module=eu.newsreader.eventcoreference.naf.EventCorefWordnetSim
  java_options="--method leacock-chodorow"
  java_options="$java_options  --wn-lmf $modulesdir/vua-resources/$lang_resource"
  java_options="$java_options  --sim 2.0"
  java_options="$java_options  --wsd 0.8"
  java_options="$java_options  --relations XPOS_NEAR_SYNONYM#HAS_HYPERONYM#HAS_XPOS_HYPERONYM#event"
  
  java -Xmx812m -cp $jarfile $java_module $java_options
}

opin() {
  cd $modulesdir/opinion_miner_deluxePP
  python tag_file.py -polarity -d hotel
  cd $workdir
}
