#!/bin/sh

set -eux

readonly WORK_DIR=$(dirname $0)/../

cd ${WORK_DIR}

files=$(git ls-files | grep ".\+\.swift")

for file in ${files};
do
  swift run swift-format lint ${file}
done