#!/bin/bash

TRACKF=$(mktemp)
WORKF=$(mktemp)
# echo $TRACKF
# SOURCES
echo '\$.*=[[:space:]]*\$_(GET|POST|REQUEST|COOKIE|FILES)' >>$TRACKF
# SINKS
export SINKS="(exec|system|popen|eval|passthru|mysqli_query)"

for x in `seq 1 7`; do
	grep -rEf $TRACKF $1 > $WORKF
	cat $WORKF | perl -ne 'if ($_ =~ m/\$(\S+?)\s*=.*\$/) { print "\\\$.*=.*\\\$$1\n"; }' >> $TRACKF
done

cat $TRACKF | sort -u | perl -ne 'if ($_ =~ m/\$(\S+?)\s*=.*\$/) { print $ENV{"SINKS"}."\\(.*\\\$$1\n"; }' >> $TRACKF
cat $TRACKF | sort -u | grep -C 2 -Hn --colour=always -rEf - $1
rm $WORKF $TRACKF
