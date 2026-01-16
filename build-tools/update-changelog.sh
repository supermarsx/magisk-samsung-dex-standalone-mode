#!/usr/bin/env bash
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
