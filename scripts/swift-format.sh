#!/bin/sh

set -eux

cd $(dirname $0)/../

while getopts "lf" opt
do
  case $opt in
    l) sub=lint;;
    f) sub=format;;
  esac
done

files=$(git ls-files | grep ".\+\.swift")

for file in ${files};
do
  swift run swift-format ${sub} ${file}
done
