#!/bin/bash
set -uo pipefail

PROP_FILE="module.prop"
JSON_FILE="update.json"

version_prop=$(grep '^version=' "$PROP_FILE" | cut -d= -f2)
versionCode_prop=$(grep '^versionCode=' "$PROP_FILE" | cut -d= -f2)

version_json=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$JSON_FILE" | head -n1 | sed 's/.*"version"[[:space:]]*:[[:space:]]*"//;s/"$//')
# Handle versionCode as either integer or string in JSON
versionCode_json=$(grep -oE '"versionCode"[[:space:]]*:[[:space:]]*(\"?)[0-9]+(\"?)' "$JSON_FILE" | head -n1 | sed 's/.*"versionCode"[[:space:]]*:[[:space:]]*"*//;s/"*$//')

status=0

if [ "$version_prop" != "$version_json" ]; then
	echo "Version mismatch: module.prop has '$version_prop' but update.json has '$version_json'"
	status=1
fi

if [ "$versionCode_prop" != "$versionCode_json" ]; then
	echo "VersionCode mismatch: module.prop has '$versionCode_prop' but update.json has '$versionCode_json'"
	status=1
fi

exit $status
