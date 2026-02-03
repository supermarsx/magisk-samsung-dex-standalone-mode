<#
.SYNOPSIS
    Prepend a new version entry to changelog.md

.DESCRIPTION
    This script prepends a new changelog entry with the version number,
    current date, and the contents of the notes file to changelog.md.
    The existing changelog content is preserved below the new entry.

.PARAMETER Version
    The version string (e.g., "2026.1")

.PARAMETER NotesFile
    Path to a file containing release notes

.EXAMPLE
    .\update-changelog.ps1 -Version "2026.1" -NotesFile "notes.txt"
#>
param(
    [Parameter(Mandatory = $true)][string]$Version,
    [Parameter(Mandatory = $true)][string]$NotesFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$changelog = Join-Path $repoRoot 'changelog.md'
if (-not (Test-Path $NotesFile)) { throw "Notes file not found: $NotesFile" }
if (-not (Test-Path $changelog)) { throw "Missing changelog.md" }

$dateStr = (Get-Date).ToString('yyyy-MM-dd')
$tmp = New-TemporaryFile

"## v$Version - $dateStr" | Out-File -FilePath $tmp -Encoding UTF8
Get-Content $NotesFile | Out-File -FilePath $tmp -Encoding UTF8 -Append
"" | Out-File -FilePath $tmp -Encoding UTF8 -Append
Get-Content $changelog | Out-File -FilePath $tmp -Encoding UTF8 -Append

Move-Item -Force $tmp $changelog

Write-Host "Changelog updated with v$Version."
