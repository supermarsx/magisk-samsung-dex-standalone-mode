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
Assert-Command gh
Assert-Command shellcheck
Assert-Command shfmt
Assert-Command bash

bash build-tools/lint.sh
bash build-tools/format.sh
bash build-tools/test.sh
bash build-tools/package.sh

$zipFile = Join-Path $RepoRoot 'magisk-samsung-dex-standalone-mode.zip'
if (-not (Test-Path $zipFile)) {
    throw "Package not found: $zipFile"
}

$versionLine = (Select-String -Path (Join-Path $RepoRoot 'module.prop') -Pattern '^version=').Matches.Value
if (-not $versionLine) {
    throw 'Unable to read version from module.prop'
}
$version = $versionLine.Split('=')[1]
$tag = "v$version"

if (git rev-parse $tag 2>$null) {
    throw "Tag already exists: $tag"
}

git add -A
if (-not (git diff --cached --quiet)) {
    git commit -m "chore: release $version"
}
else {
    Write-Host 'No changes to commit before tagging.'
}

git tag -a $tag -m "Release $version"

gh release create $tag $zipFile --title $tag --notes "Release $version"

Write-Host "Release $tag created and artifact uploaded."
