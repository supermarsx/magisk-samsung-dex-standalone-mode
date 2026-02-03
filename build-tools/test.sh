#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash scripts/check-version.sh
bash tests/run-tests.sh
bash tests/test-build-create-module.sh
bash tests/test-build-delete-module.sh
bash tests/test-release-scripts.sh
