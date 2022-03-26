#!/bin/sh

set -eux

cd $(dirname $0)/../

rm -rf TestReports

scheme=TemplateView

swift run xchtmlreport -r ${scheme}/TestResults

mkdir -p TestReports TestReports/${scheme}

mv ${scheme}/index.html TestReports/${scheme}/index.html
