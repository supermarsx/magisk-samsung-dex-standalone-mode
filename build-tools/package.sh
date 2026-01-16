#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

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
