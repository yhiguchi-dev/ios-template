#!/bin/sh

set -eux

cd $(dirname $0)/../

mkdir -p config

envsubst < ./scripts/Default.xcconfig.template > ./config/Default.xcconfig
