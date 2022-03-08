#!/bin/sh

set -eux

cd $(dirname $0)/../

mkdir -p config

envsubst < ./scripts/Env.xcconfig.template > ./config/Env.xcconfig
