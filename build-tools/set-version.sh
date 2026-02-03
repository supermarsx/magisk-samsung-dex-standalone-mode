#!/usr/bin/env bash
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
sed -i -E 's/("versionCode"[[:space:]]*:[[:space:]]*)[0-9]+/\1'"${version_code}"'/' update.json

echo "Updated module.prop and update.json to version ${version} (code ${version_code})."
