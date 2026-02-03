#!/usr/bin/env bash
#
# update-changelog.sh - Prepend a new version entry to changelog.md
#
# Usage: ./update-changelog.sh <version> <notes-file>
#
# Arguments:
#   version    - The version string (e.g., "2026.1")
#   notes-file - Path to a file containing release notes
#
# This script prepends a new changelog entry with the version number,
# current date, and the contents of the notes file to changelog.md.
# The existing changelog content is preserved below the new entry.
#
# Examples:
#   ./update-changelog.sh 2026.1 release-notes.txt
#   echo "- Bug fix" > notes.txt && ./update-changelog.sh 2026.2 notes.txt
#
set -euo pipefail

if [ $# -ne 2 ]; then
	echo "Usage: $0 <version> <notes-file>" >&2
	exit 1
fi

version=$1
notes_file=$2

[ -f "$notes_file" ] || {
	echo "Notes file not found: $notes_file" >&2
	exit 1
}
[ -f changelog.md ] || {
	echo "Missing changelog.md" >&2
	exit 1
}

date_str=$(date +%Y-%m-%d)
tmp=$(mktemp)
{
	echo "## v${version} - ${date_str}"
	cat "$notes_file"
	echo
	cat changelog.md
} >"$tmp"

mv "$tmp" changelog.md

echo "Changelog updated with v${version}."
