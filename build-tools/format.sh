#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require() { command -v "$1" >/dev/null 2>&1 || {
	echo "Missing required command: $1"
	exit 1
}; }
require git
require shfmt

shell_files=()
while IFS= read -r file; do
	shell_files+=("$file")
done < <(git ls-files '*.sh')

if ((${#shell_files[@]})); then
	shfmt -d "${shell_files[@]}"
else
	echo "No shell scripts found to format."
fi
