#!/bin/bash
pushd lambda/influence-analysis-II || exit 1
set -e
./gradlew clean build
popd || exit 1
