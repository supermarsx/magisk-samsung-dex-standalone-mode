<#
.SYNOPSIS
    Full release automation script (PowerShell version)

.DESCRIPTION
    This script performs a complete release:
      1. Updates version in module.prop and update.json
      2. Updates changelog.md with release notes
      3. Runs linting (shellcheck) and format checks (shfmt)
      4. Runs all tests
      5. Builds the module ZIP package
      6. Commits all changes
      7. Creates an annotated git tag
      8. Creates a GitHub release with the ZIP attached

.NOTES
    Environment variables (required):
      VERSION              - The version string (e.g., "2026.1")
      VERSION_CODE         - The numeric version code (e.g., "4")
      CHANGELOG_NOTES_FILE - Path to file containing release notes

    Prerequisites: git, gh (GitHub CLI), shellcheck, shfmt, bash

.EXAMPLE
    $env:VERSION = "2026.1"
    $env:VERSION_CODE = "4"
    $env:CHANGELOG_NOTES_FILE = "notes.txt"
    .\release.ps1
#>
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

$Version = $env:VERSION
$VersionCode = $env:VERSION_CODE
$NotesFile = $env:CHANGELOG_NOTES_FILE

if (-not $Version -or -not $VersionCode -or -not $NotesFile) {
    throw 'Set VERSION, VERSION_CODE, and CHANGELOG_NOTES_FILE before running release.'
}

bash build-tools/set-version.sh $Version $VersionCode
bash build-tools/update-changelog.sh $Version $NotesFile

bash build-tools/lint.sh
bash build-tools/format.sh
bash build-tools/test.sh
bash build-tools/package.sh

$zipFile = Join-Path $RepoRoot 'magisk-samsung-dex-standalone-mode.zip'
if (-not (Test-Path $zipFile)) {
    throw "Package not found: $zipFile"
}

$versionLine = (Select-String -Path (Join-Path $RepoRoot 'module.prop') -Pattern '^version=').Line
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
