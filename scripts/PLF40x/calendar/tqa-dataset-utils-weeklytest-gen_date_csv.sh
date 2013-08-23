#!/bin/bash
start=1356924297
for i in {1..365}; do
echo $i,`date -d @"$((start + 86400*i))" +%m/%d/%Y` >>2013.csv
done
