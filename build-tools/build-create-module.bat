@echo off
setlocal enabledelayedexpansion

:: Startup message
echo Creating module.

:: Zip file name, module name
set ZIPFILE=magisk-samsung-dex-standalone-mode.zip

:: ZIP file message
echo ZIP module name, "%ZIPFILE%".

:: List file
set LISTFILE=build-filelist.txt

:: Check if list file exists
if not exist %LISTFILE% (
    echo File list file, "%LISTFILE%" not found!
    goto quit_with_error
) else (
    echo File list file, "%LISTFILE%" was found.
)

:: Check if ZIP file exists and delete it if it does
if exist "%ZIPFILE%" (
    del "%ZIPFILE%"
    echo Deleted existing ZIP module, "%ZIPFILE%".
) else (
    echo No old ZIP module was found.
)

:: Prepare the list of items to include in the ZIP
set "FILELIST="
echo Preparing file list.
for /f "delims=" %%i in (%LISTFILE%) do (
    set "FILELIST=!FILELIST! '%CD%\%%i',"
)

:: Remove the leading comma and space if they exist
echo Filtering file list.
if "!FILELIST:~0,2!" == ", " (
    set "FILELIST=!FILELIST:~2!"
)

:: Remove the trailing comma if it exists
if "!FILELIST:~-1!" == "," (
    set "FILELIST=!FILELIST:~0,-1!"
)

:: Execute PowerShell to create the ZIP file
echo Creating ZIP module.
powershell -NoProfile -ExecutionPolicy Bypass ^
  "Compress-Archive -Path @(%FILELIST%) -DestinationPath '%CD%\%ZIPFILE%' -Force"
if not exist "%ZIPFILE%" (
    echo Failed to create ZIP module, "%ZIPFILE%".
    goto quit_with_error
)
echo Created ZIP module, "%ZIPFILE%".
endlocal

:: Quit script
:quit
echo Done.
exit /b 0

:: Quit with error
:quit_with_error
echo Critical error, quitting..
exit /b 1
