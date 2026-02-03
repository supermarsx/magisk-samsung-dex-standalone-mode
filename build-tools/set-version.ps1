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

$json = Get-Content $jsonFile | ConvertFrom-Json
$json.version = $Version
$json.versionCode = [int]$VersionCode
$json | ConvertTo-Json | Set-Content $jsonFile

Write-Host "Updated module.prop and update.json to version $Version (code $VersionCode)."
