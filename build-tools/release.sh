#!/usr/bin/env bash
#
# release.sh - Full release automation script
#
# Usage: VERSION=x.x VERSION_CODE=n CHANGELOG_NOTES_FILE=notes.txt ./release.sh
#
# Environment variables (required):
#   VERSION             - The version string (e.g., "2026.1")
#   VERSION_CODE        - The numeric version code (e.g., "4")
#   CHANGELOG_NOTES_FILE - Path to file containing release notes
#
# This script performs a complete release:
#   1. Updates version in module.prop and update.json
#   2. Updates changelog.md with release notes
#   3. Runs linting (shellcheck) and format checks (shfmt)
#   4. Runs all tests
#   5. Builds the module ZIP package
#   6. Commits all changes
#   7. Creates an annotated git tag
#   8. Creates a GitHub release with the ZIP attached
#
# Prerequisites:
#   - git, gh (GitHub CLI), shellcheck, shfmt, bash, zip
#
# Example:
#   VERSION=2026.1 VERSION_CODE=4 CHANGELOG_NOTES_FILE=notes.txt ./release.sh
#
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
