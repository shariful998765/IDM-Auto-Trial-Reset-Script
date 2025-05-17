@echo off
setlocal

:: Title
title IDM Auto Trial Reset - Remover.

echo.====================================================
echo     IDM Auto Reset Remover
echo     Stops and removes auto-reset script
echo.====================================================
echo.

:: Step 1: Stop running process
echo [1/5] Stopping any running instances...
tasklist | findstr /i "cmd.exe" >nul && (
    for /f "tokens=2" %%a in ('tasklist ^| findstr /i "cmd.exe" ^| findstr /i "idm_reset"') do (
        set pid=%%a
        echo Found running process with PID=!pid!
        taskkill /PID !pid! /F >nul 2>&1
        echo Stopped process !pid!
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

:: Step 4: Delete log file
echo.[4/5] Deleting log file...
set "logFile=%~dp0%idm_auto_trial_reset.log"
if exist "%logFile%" (
    del /q "%logFile%" >nul 2>&1
    echo Log file deleted.
) else (
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