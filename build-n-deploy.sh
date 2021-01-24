#!/bin/bash
pushd lambda/influence-analysis || exit 1
set -e
./gradlew clean build
popd || exit 1
