#!/usr/bin/env bash
set -o errexit


DART_LOCATION=features/fixtures/mazerunner/lib

BS_DART_LOACTION=features/fixture_resources

echo "copy over dart code"

rm -rf "$BS_DART_LOACTION/lib"

cp -r $DART_LOCATION $BS_DART_LOACTION