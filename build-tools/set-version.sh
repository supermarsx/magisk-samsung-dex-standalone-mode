#!/usr/bin/env bash
#
# set-version.sh - Update version numbers in module.prop and update.json
#
# Usage: ./set-version.sh <version> <versionCode>
#
# Arguments:
#   version     - The version string (e.g., "2026.1")
#   versionCode - The numeric version code (e.g., "4")
#
# This script updates both module.prop and update.json to keep version
# information synchronized. The versionCode is stored as a quoted string
# in update.json as required by Magisk.
#
# Examples:
#   ./set-version.sh 2026.1 4
#   ./set-version.sh 2026.2 5
#
set -euo pipefail

if [ $# -ne 2 ]; then
	echo "Usage: $0 <version> <versionCode>" >&2
	exit 1
fi

version=$1
version_code=$2

for file in module.prop update.json; do
	[ -f "$file" ] || {
		echo "Missing file: $file" >&2
		exit 1
	}
done

sed -i -E "s/^version=.*/version=${version}/" module.prop
sed -i -E "s/^versionCode=.*/versionCode=${version_code}/" module.prop

sed -i -E 's/("version"[[:space:]]*:[[:space:]]*)"[^"]*"/\1"'"${version}"'"/' update.json
sed -i -E 's/("versionCode"[[:space:]]*:[[:space:]]*)[^,]*/\1"'"${version_code}"'"/' update.json

echo "Updated module.prop and update.json to version ${version} (code ${version_code})."
