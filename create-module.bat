@echo off
setlocal enabledelayedexpansion

REM Zip file name, module name
set ZIPFILE=magisk-samsung-dex-standalone-mode.zip

REM List file
set LISTFILE=filelist.txt

REM Check if list file exists
if not exist %LISTFILE% (
    echo List file %LISTFILE% not found!
    exit /b 1
)

REM Check if ZIP file exists and delete it if it does
if exist "%ZIPFILE%" (
    del "%ZIPFILE%"
    echo Deleted existing ZIP file: %ZIPFILE%
)

REM Prepare the list of items to include in the ZIP
set "FILELIST="
for /f "delims=" %%i in (%LISTFILE%) do (
    set "FILELIST=!FILELIST! '%CD%\%%i',"
)

REM Remove the leading comma and space if they exist
if "!FILELIST:~0,2!" == ", " (
    set "FILELIST=!FILELIST:~2!"
)

REM Remove the trailing comma if it exists
if "!FILELIST:~-1!" == "," (
    set "FILELIST=!FILELIST:~0,-1!"
)

REM Execute PowerShell to create the ZIP file
powershell -NoProfile -ExecutionPolicy Bypass ^
    "Compress-Archive -Path @(%FILELIST%) -DestinationPath '%CD%\%ZIPFILE%' -Force"

echo ZIP file created: %ZIPFILE%
endlocal
