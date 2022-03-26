#!/bin/sh

set -eux

cd "$(dirname "$0")"/../

scheme=TemplateView
destination='platform=iOS Simulator,name=iPhone 8,OS=15.2'

rm -rf TestReports

mkdir -p TestReports TestReports/${scheme}

cd ${scheme}

xcodebuild test -scheme ${scheme} -destination "${destination}" -derivedDataPath "${DERIVED_DATA_PATH}" -resultBundlePath ../TestReports/${scheme}/TestResults

cd ../

swift run xchtmlreport -r TestReports/${scheme}/TestResults
