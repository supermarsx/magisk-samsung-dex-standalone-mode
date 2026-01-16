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
Assert-Command shfmt

$shellFiles = git ls-files '*.sh'
if ($shellFiles) {
    shfmt -d $shellFiles
}
else {
    Write-Host "No shell scripts found to format."
}
