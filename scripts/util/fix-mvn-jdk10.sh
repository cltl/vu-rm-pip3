#!/bin/sh
#
# fixes a compatibility issue between maven's compile plugin
# and java 10
# author: Sophie Arnoult
# date: 24/03/2019
#----------------------------------------------------

pom=$1

# Indentation
d="  "
d2="$d$d"
d3="$d2$d"
d4="$d3$d"
d5="$d4$d"
d6="$d5$d"

# fix string
fix="$d4<maven.compiler.source>1.6</maven.compiler.source>
$d4<maven.compiler.target>1.6</maven.compiler.target>"

# inserts fix in pom
full_length=$(cat $pom | wc -l)
plugins_line=$(grep -n "<properties>" $pom | cut -d":" -f 1)
head -$plugins_line $pom > pom1
rest=$((full_length - plugins_line))
tail -$rest $pom > pom2
echo "$fix" > pom_insert
cat pom1 pom_insert pom2 > $pom

rm pom1
rm pom_insert
rm pom2
