#!/bin/bash
set -euo pipefail

PROP_FILE="module.prop"
JSON_FILE="update.json"

# Determine current version components
current_version=$(grep '^version=' "$PROP_FILE" | cut -d= -f2)
current_year=${current_version%%.*}
current_increment=${current_version##*.}
current_year_now=$(date +%Y)

if [ "$current_year_now" != "$current_year" ]; then
	new_increment=1
else
	new_increment=$((current_increment + 1))
fi

new_version="${current_year_now}.${new_increment}"

# Update module.prop
sed -i -E "s/^version=.*/version=${new_version}/" "$PROP_FILE"
sed -i -E "s/^versionCode=.*/versionCode=${new_increment}/" "$PROP_FILE"

# Update update.json
sed -i -E 's/("version"[[:space:]]*:[[:space:]]*)"[^"]*"/\1"'"${new_version}"'"/' "$JSON_FILE"
sed -i -E 's/("versionCode"[[:space:]]*:[[:space:]]*)[^,]*/\1"'"${new_increment}"'"/' "$JSON_FILE"

# Build module zip
bash build-tools/build-create-module.sh

# Commit and tag
git add "$PROP_FILE" "$JSON_FILE"
git commit -m "chore: release ${new_version}" && git tag "v${new_version}"
