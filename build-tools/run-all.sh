#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
require() { command -v "$1" >/dev/null 2>&1 || {
	echo "Missing required command: $1"
	exit 1
}; }

require git
require shellcheck
require shfmt
require bash
require zip

shell_files=()
while IFS= read -r file; do
	shell_files+=("$file")
done < <(git ls-files '*.sh')

if ((${#shell_files[@]})); then
	shellcheck "${shell_files[@]}"
	shfmt -d "${shell_files[@]}"
else
	echo "No shell scripts found to lint/format."
fi

bash scripts/check-version.sh
bash tests/run-tests.sh
bash tests/test-build-create-module.sh
bash tests/test-build-delete-module.sh

cleanup_list() {
	if [[ "${temp_list_created:-0}" -eq 1 ]]; then
		rm -f "$ROOT/build-filelist.txt"
	fi
}
trap cleanup_list EXIT

temp_list_created=0
if [[ ! -f "$ROOT/build-filelist.txt" ]]; then
	cp "$ROOT/build-tools/build-filelist.txt" "$ROOT/build-filelist.txt"
	temp_list_created=1
fi

bash build-tools/build-create-module.sh

echo "Lint, format, tests, and packaging completed successfully."
