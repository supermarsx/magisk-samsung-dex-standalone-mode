#!/bin/bash

# Startup message
echo Creating module.

# Zip file name, module name
ZIPFILE="magisk-samsung-dex-standalone-mode.zip"

# ZIP file message
echo ZIP module name, "${ZIPFILE}".

# List file
LISTFILE="build-filelist.txt"

# Check if list file exists
if [ ! -f "${LISTFILE}" ]; then
    echo File list file, "${LISTFILE}" not found!
    exit 1
else
    echo File list file, "${LISTFILE}" was found.
fi

# Check if ZIP file exists and delete it if it does
if [ -f "${ZIPFILE}" ]; then
    rm "${ZIPFILE}"
    echo Deleted existing ZIP module, "${ZIPFILE}".
fi

# Prepare the list of items to include in the ZIP
FILELIST=()
echo Preparing file list.
while IFS= read -r line; do
    FILELIST+=("${PWD}/${line}")
done < "${LISTFILE}"

# Execute zip command to create the ZIP file
echo Creating ZIP module.
if ! zip "${ZIPFILE}" -r "${FILELIST[@]}"; then
  echo Failed to create ZIP module, "${ZIPFILE}".
    exit 1
fi
echo Created ZIP module, "${ZIPFILE}".

echo Done.
exit 0
