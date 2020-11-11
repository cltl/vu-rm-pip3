#!/bin/bash
#
# Checks if connection to port 2060 (spotlight port for Dutch)
# is open, and launches spotlight server otherwise.
#-----------------------------------------------------
spotlightdir=$1
port=$2
if ! curl -I http://localhost:$port/rest/ > /dev/null 2>&1; then
  >&2 echo "launching dbpedia spotlight server"
  java -jar -Xmx2000m $spotlightdir/dbpedia-spotlight-0.7.1.jar $spotlightdir/nl http://localhost:$port/rest &> spotlight.log &

  max=6
  i=0
  while ! lsof -Pi :$port >/dev/null && [ $i -le $max ]; do
    >&2 echo "waiting for connection..."
    sleep 20
    i=$((i+1))
  done
  if ! lsof -Pi :$port >/dev/null; then
    >&2 echo "failed to establish connection in allocated time"
  fi
else
  >&2 echo "connection to dbpedia spotlight server is already established"
fi
exit
