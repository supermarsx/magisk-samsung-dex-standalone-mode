Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

function Assert-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Missing required command: $Name"
    }
}

Assert-Command git
Assert-Command shellcheck
Assert-Command shfmt
Assert-Command bash

$shellFiles = git ls-files '*.sh'
if ($shellFiles) {
    shellcheck $shellFiles
    shfmt -d $shellFiles
}
else {
    Write-Host "No shell scripts found to lint/format."
}

bash scripts/check-version.sh
bash tests/run-tests.sh
bash tests/test-build-delete-module.sh
pwsh tests/test-build-create-module.ps1

cmd /c build-tools\build-create-module.bat

Write-Host "Lint, format, tests, and packaging completed successfully."
