#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require() { command -v "$1" >/dev/null 2>&1 || {
	echo "Missing required command: $1"
	exit 1
}; }

require git
require gh
require shellcheck
require shfmt
require bash
require zip

VERSION=${VERSION:-}
VERSION_CODE=${VERSION_CODE:-}
CHANGELOG_NOTES_FILE=${CHANGELOG_NOTES_FILE:-}

if [[ -z "$VERSION" || -z "$VERSION_CODE" || -z "$CHANGELOG_NOTES_FILE" ]]; then
	echo "Set VERSION, VERSION_CODE, and CHANGELOG_NOTES_FILE before running release." >&2
	exit 1
fi

bash build-tools/set-version.sh "$VERSION" "$VERSION_CODE"
bash build-tools/update-changelog.sh "$VERSION" "$CHANGELOG_NOTES_FILE"

bash build-tools/lint.sh
bash build-tools/format.sh
bash build-tools/test.sh
bash build-tools/package.sh

ZIPFILE="$ROOT/magisk-samsung-dex-standalone-mode.zip"
[[ -f "$ZIPFILE" ]] || {
	echo "Package not found: $ZIPFILE"
	exit 1
}

version=$(grep '^version=' module.prop | cut -d= -f2)
[[ -n "$version" ]] || {
	echo "Unable to read version from module.prop"
	exit 1
}
TAG="v$version"

if git rev-parse "$TAG" >/dev/null 2>&1; then
	echo "Tag already exists: $TAG"
	exit 1
fi

git add -A
if ! git diff --cached --quiet; then
	git commit -m "chore: release $version"
else
	echo "No changes to commit before tagging."
fi

git tag -a "$TAG" -m "Release $version"

gh release create "$TAG" "$ZIPFILE" --title "$TAG" --notes "Release $version"

echo "Release $TAG created and artifact uploaded."
