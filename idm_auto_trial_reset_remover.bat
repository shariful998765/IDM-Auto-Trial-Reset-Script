@echo off
setlocal

:: Title
title IDM Auto Trial Reset - Remover

cls
echo.====================================================
echo     IDM Auto Reset Remover
echo     Stops and removes auto-reset script
echo.====================================================
echo.

:: Step 1: Stop running instance(s)
echo [1/5] Stopping any running instances...
wmic process where "commandline like '%%%%idm_auto_trial_reset%%%%'" get ProcessId 2>nul | findstr [0-9] >nul && (
    for /f "skip=1 tokens=1" %%a in ('wmic process where "commandline like '%%%%idm_auto_trial_reset%%%%'" get ProcessId') do (
        echo Found running process with PID=%%a
        taskkill /PID %%a /F >nul 2>&1
        echo Stopped process %%a
    )
) || (
    echo No running instance found.
)

:: Step 2: Remove from startup
echo.[2/5] Removing from startup folder...
set "startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "shortcutPath=%startupFolder%\idm_auto_trial_reset.bat"

if exist "%shortcutPath%" (
    del /q "%shortcutPath%" >nul 2>&1
    echo Removed idm_auto_trial_reset.bat from startup.
) else (
    echo Not found in startup.
)

:: Step 3: Delete marker file
echo.[3/5] Deleting marker file...
set "markerFile=%temp%\idm_reset_marker"
if exist "%markerFile%" (
    del /q "%markerFile%" >nul 2>&1
    echo Marker file deleted.
) else (
    echo Marker file not found.
)

:: Step 4: Delete log file (from %temp% or current dir)
echo.[4/5] Deleting log file...

set "logFileInTemp=%temp%\idm_reset.log"
set "logFileInDir=%~dp0idm_auto_trial_reset.log"

if exist "%logFileInTemp%" (
    del /q "%logFileInTemp%" >nul 2>&1
    echo Deleted log file from temp folder.
)

if exist "%logFileInDir%" (
    del /q "%logFileInDir%" >nul 2>&1
    echo Deleted log file from current directory.
)

if not exist "%logFileInTemp%" if not exist "%logFileInDir%" (
    echo Log file not found.
)

:: Step 5: Delete main script if exists (optional)
echo.[5/5] Checking for main script in current directory...
set "mainScript=idm_auto_trial_reset.bat"
if exist "%mainScript%" (
    del /q "%mainScript%" >nul 2>&1
    echo Main script (%mainScript%) deleted.
) else (
    echo Main script not found here.
)

echo.
echo ✅ Uninstallation complete. All components removed.
echo.
pause
