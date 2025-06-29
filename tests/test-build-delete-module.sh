#!/bin/bash
set -e

# Create temporary workspace
TMPDIR=$(mktemp -d)
cp -r . "$TMPDIR/repo"
cd "$TMPDIR/repo"

ZIPFILE=magisk-samsung-dex-standalone-mode.zip

# Create a dummy zip to delete
touch "$ZIPFILE"

bash build-tools/build-delete-module.sh

if [ -f "$ZIPFILE" ]; then
  echo "ZIP not deleted"
  exit 1
fi

echo "build-delete-module test passed"
