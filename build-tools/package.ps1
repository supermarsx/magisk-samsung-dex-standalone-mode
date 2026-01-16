Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

if (-not (Test-Path "$RepoRoot/build-filelist.txt")) {
    Copy-Item "$RepoRoot/build-tools/build-filelist.txt" "$RepoRoot/build-filelist.txt"
    $tempListCreated = $true
}
else {
    $tempListCreated = $false
}

try {
    cmd /c build-tools\build-create-module.bat
}
finally {
    if ($tempListCreated) {
        Remove-Item "$RepoRoot/build-filelist.txt" -ErrorAction SilentlyContinue
    }
}
