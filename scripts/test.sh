#!/bin/sh

set -eux

cd $(dirname $0)/../

scheme=TemplateView
destination='platform=iOS Simulator,name=iPhone 8,OS=15.2'

cd ${scheme}

rm -rf TestResults TestResults.xcresult

xcodebuild test -scheme ${scheme} -destination "${destination}" -derivedDataPath ${DERIVED_DATA_PATH} -resultBundlePath TestResults
