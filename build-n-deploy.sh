#!/bin/bash
pushd lambda/influence-analysis || exit 1
set -e
./gradlew clean build -i
popd || exit 1
