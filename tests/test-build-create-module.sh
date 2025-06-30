#!/bin/bash
set -e

# Create temporary workspace
TMPDIR=$(mktemp -d)
cp -r . "$TMPDIR/repo"
cd "$TMPDIR/repo"

# Provide required files for build script
ln -s build-tools/build-filelist.txt build-filelist.txt

bash build-tools/build-create-module.sh

ZIPFILE=magisk-samsung-dex-standalone-mode.zip

if [ ! -f "$ZIPFILE" ]; then
  echo "ZIP not created"
  exit 1
fi

zipinfo -1 "$ZIPFILE" > zip.list

required_paths=(
  "META-INF/com/google/android/update-binary"
  "META-INF/com/google/android/update-script"
  "customize.sh"
  "module.prop"
  "post-fs-data.sh"
  "skip_mount"
  "debug/debug-unmount.sh"
  "update.json"
)

for path in "${required_paths[@]}"; do
  if ! grep -q "$path" zip.list; then
    echo "Missing $path"
    exit 1
  fi
done

echo "build-create-module test passed"
