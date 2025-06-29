#!/bin/sh
set -e

echo Deleting ZIP module.

ZIPFILE="magisk-samsung-dex-standalone-mode.zip"

if [ -f "$ZIPFILE" ]; then
  rm "$ZIPFILE"
    echo Deleted existing ZIP module, "$ZIPFILE".
else
    echo No ZIP module, "$ZIPFILE".
fi

echo Done.
exit 0
