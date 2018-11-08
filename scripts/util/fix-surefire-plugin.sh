#!/bin/sh
#
# fixes a compatibility issue between maven's surefire plugin
# and docker (for heideltime and event-coreference modules)
# date: 08/11/2018
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
fix="$d3<plugin>
$d4<artifactId>maven-surefire-plugin</artifactId>
$d4<version>2.17</version>
$d4<configuration>
$d5<includes>
$d6<include>**/*Test.java</include>
$d5</includes>
$d5<useSystemClassLoader>false</useSystemClassLoader>
$d4</configuration>
$d3</plugin>"

# inserts fix in pom
full_length=$(cat $pom | wc -l)
plugins_line=$(grep -n "<plugins>" $pom | cut -d":" -f 1)
head -$plugins_line $pom > pom1
rest=$((full_length - plugins_line))
tail -$rest $pom > pom2
echo "$fix" > pom_insert
cat pom1 pom_insert pom2 > $pom

rm pom1
rm pom_insert
rm pom2
