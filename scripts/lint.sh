#!/bin/sh

set -eux

cd $(dirname $0)
cd ..

files=$(git ls-files | grep ".\+\.swift")

for file in ${files};
do
  swift run swift-format lint ${file}
done