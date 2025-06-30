# PowerShell build test for Windows
$ErrorActionPreference = 'Stop'

# Create temporary workspace
$TmpDir = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath()) -Name ([System.IO.Path]::GetRandomFileName())
Copy-Item -Recurse . "$TmpDir\repo"
Set-Location "$TmpDir\repo"

# Provide required files for build script
Copy-Item build-tools\build-filelist.txt build-filelist.txt

cmd /c build-tools\build-create-module.bat

$ZipFile = "magisk-samsung-dex-standalone-mode.zip"
if (-not (Test-Path $ZipFile)) {
    Write-Host "ZIP not created"
    exit 1
}

$Extract = Join-Path $Pwd 'extract'
Expand-Archive -Path $ZipFile -DestinationPath $Extract -Force

$RequiredPaths = @(
    'META-INF/com/google/android/update-binary',
    'META-INF/com/google/android/update-script',
    'customize.sh',
    'module.prop',
    'post-fs-data.sh',
    'skip_mount',
    'debug/debug-unmount.sh',
    'update.json'
)
foreach ($path in $RequiredPaths) {
    if (-not (Test-Path (Join-Path $Extract $path))) {
        Write-Host "Missing $path"
        exit 1
    }
}

Write-Host "build-create-module windows test passed"
