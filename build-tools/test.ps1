Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

bash scripts/check-version.sh
bash tests/run-tests.sh
bash tests/test-build-delete-module.sh
pwsh tests/test-build-create-module.ps1
