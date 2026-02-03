<#
.SYNOPSIS
    Update version numbers in module.prop and update.json

.DESCRIPTION
    This script updates both module.prop and update.json to keep version
    information synchronized. The versionCode is stored as a quoted string
    in update.json as required by Magisk.

.PARAMETER Version
    The version string (e.g., "2026.1")

.PARAMETER VersionCode
    The numeric version code (e.g., "4")

.EXAMPLE
    .\set-version.ps1 -Version "2026.1" -VersionCode "4"
#>
param(
    [Parameter(Mandatory = $true)][string]$Version,
    [Parameter(Mandatory = $true)][string]$VersionCode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$propFile = Join-Path $repoRoot 'module.prop'
$jsonFile = Join-Path $repoRoot 'update.json'
foreach ($file in @($propFile, $jsonFile)) {
    if (-not (Test-Path $file)) {
        throw "Missing file: $file"
    }
}

(Get-Content $propFile) -replace '^version=.*$', "version=$Version" -replace '^versionCode=.*$', "versionCode=$VersionCode" | Set-Content $propFile

(Get-Content $jsonFile) -replace '"version"\s*:\s*"[^"]*"', '"version": ' + '"' + $Version + '"' -replace '"versionCode"\s*:\s*"[^"]*"', '"versionCode": ' + '"' + $VersionCode + '"' | Set-Content $jsonFile

Write-Host "Updated module.prop and update.json to version $Version (code $VersionCode)."
