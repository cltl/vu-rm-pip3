#!/bin/bash
#
# Checks if connection to port 2060 (spotlight port for Dutch) 
# is open, and launches spotlight server otherwise.
#-----------------------------------------------------
spotlightdir=$1

if ! lsof -Pi :2060 >/dev/null ; then
  >&2 echo "launching dbpedia spotlight server"
  java -jar -Xmx2000m $spotlightdir/dbpedia-spotlight-0.7.1.jar $spotlightdir/nl http://localhost:2060/rest &>/dev/null &
  
  max=6
  i=0
  while ! lsof -Pi :2060 >/dev/null && [ $i -le $max ]; do
    >&2 echo "waiting for connection..."
    sleep 20
    i=$((i+1))
  done
  if ! lsof -Pi :2060 >/dev/null; then
    >&2 echo "failed to establish connection in allocated time"
  fi
else
  >&2 echo "connection to dbpedia spotlight server is already established"
fi
exit
