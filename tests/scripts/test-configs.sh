#!/bin/bash
#
# Test user/docker script options
#---------------------------------------------------
workdir=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../.. && pwd)
cd $workdir
outdir=$1

test_all() {
  for m in all opinions srl
  do
    ./run-pipeline-dkr.sh -m $m tests/data/four_words.txt > $outdir/test-$m.out 2> $outdir/test-$m.log
    grep "failed" $outdir/test-$m.log
    ./run-pipeline-dkr.sh -m $m -t 0.1 tests/data/four_words.txt > $outdir/test-$m-t01.out 2> $outdir/test-$m-t01.log
    grep "failed" $outdir/test-$m-t01.log
    ./run-pipeline-dkr.sh -m $m -o hotel tests/data/four_words.txt > $outdir/test-$m-hotel.out 2> $outdir/test-$m-hotel.log
    grep "failed" $outdir/test-$m-hotel.log
    ./run-pipeline-dkr.sh -m $m -o hotelnews tests/data/four_words.txt > $outdir/test-$m-hotelnews.out 2> $outdir/test-$m-hotelnews.log
    grep "failed" $outdir/test-$m-hotelnews.log
    ./run-pipeline-dkr.sh -m $m -n tests/data/four_words.txt > $outdir/test-$m-n.out 2> $outdir/test-$m-n.log
    grep "failed" $outdir/test-$m-n.log
  done
}

test_all
