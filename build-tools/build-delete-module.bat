@echo off
setlocal enabledelayedexpansion

:: Startup message
echo Deleting ZIP module.

:: Zip file name, module name
set ZIPFILE=magisk-samsung-dex-standalone-mode.zip

:: Check if ZIP file exists and delete it if it does
if exist "%ZIPFILE%" (
    del "%ZIPFILE%"
    echo Deleted existing ZIP module, "%ZIPFILE%".
) else (
    echo No ZIP module, "%ZIPFILE%".
)

endlocal

echo Done.
exit /b 0