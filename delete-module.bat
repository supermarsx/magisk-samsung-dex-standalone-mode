@echo off
setlocal enabledelayedexpansion

REM Zip file name, module name
set ZIPFILE=magisk-samsung-dex-standalone-mode.zip

REM Check if ZIP file exists and delete it if it does
if exist "%ZIPFILE%" (
    del "%ZIPFILE%"
    echo Deleted existing ZIP file: %ZIPFILE%
)