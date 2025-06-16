@echo off
setlocal enabledelayedexpansion

:: Set console mode for better UI
mode 85,22

:: ANSI color codes
set "black=[30m"
set "red=[31m"
set "green=[32m"
set "yellow=[33m"
set "blue=[34m"
set "cyan=[36m"
set "reset=[0m"

:: Script metadata
set "version=2.6"
set "scriptName=IDM Auto Reset Tool"
set "author=Sharif"
set "username=%USERNAME%"
set "hostname=%COMPUTERNAME%"

:: thanks to ai, a lot of support got from ai

:: Paths
::set "logFile=%~dp0%idm_reset_manual.log"
set "logFile=%temp%\idm_reset_manual.log"
::set "markerFile=%~dp0%idm_reset_marker"
set "markerFile=%temp%\idm_reset_marker"

:: Define CLSIDs once
set CLSID_LIST=^
    {7B8E9164-324D-4A2E-A46D-0165FB2000EC} ^
    {6DDF00DB-1234-46EC-8356-27E7B2051192} ^
    {D5B91409-A8CA-4973-9A0B-59F713D25671} ^
    {5ED60779-4DE2-4E07-B862-974CA4FF2E9C} ^
    {07999AC3-058B-40BF-984F-69EB1E554CA7} ^
    {E8CF4E59-B7A3-41F2-86C7-82B03334F22A} ^
    {9C9D53D4-A978-43FC-93E2-1C21B529E6D7} ^
    {79873CC5-3951-43ED-BDF9-D8759474B6FD} ^
    {E6871B76-C3C8-44DD-B947-ABFFE144860D}

:: Registry root list
set ROOT_LIST=HKCU HKLM HKU\.DEFAULT
set NODE_LIST="" "Wow6432Node"

:: Additional IDM-specific paths
set IDM_PATHS=^
    "HKCU\Software\Download Manager" ^
    "HKCU\Software\Wow6432Node\Download Manager" ^
    "HKLM\Software\Internet Download Manager" ^
    "HKLM\Software\Wow6432Node\Internet Download Manager"


:: Check if already running in silent mode
if /i "%~1"=="SILENT" goto MAIN_PROCESS


cls
REM Check if running with administrative privileges
::-------------------------------------------------------------------------------
"%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\uac.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%TEMP%\uac.vbs"
    "%TEMP%\uac.vbs"
    del /q /f "%TEMP%\uac.vbs"
    exit /b
) else (
    GOTO UAC2
)
:UAC2
IF EXIST "%TEMP%\uac.vbs" (del /q /f "%TEMP%\uac.vbs")
pushd %CD% & CD /d %~dp0
::-------------------------------------------------------------------------------

:: Check if IDM is installed
if not exist "%ProgramFiles%\Internet Download Manager\IDMan.exe" ^
if not exist "%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe" (
    echo [!]  %red%IDM not found in default installation directories.%reset%
    echo %yellow%Please install Internet Download Manager first.%reset%
    timeout /t 5 >nul
    exit /b
)

:: Title
title Completely Auto Reset IDM Registry (Auto Trail Reset) v%version%

:: User Configuration Prompt
cls
echo.
echo   %blue%==========================================================================%reset%
echo      %green%Completely Auto Reset IDM Registry with Custom Background Intervals%reset%
echo                        %yellow%Version %version%%reset%
echo                  %cyan%Now Supports Custom Intervals%reset%
echo     %cyan%https://github.com/shariful998765/IDM-Auto-Trial-Reset-Script.git%reset%
echo     %yellow%See LOGS: %logFile%%reset%
echo   %blue%==========================================================================%reset%
echo.
:: - This is the one-time setup. After this:
:: - To setup the script will run automatically in background via schedule.

echo   %cyan%Please select reset interval:%reset%
echo                %green%1.%reset% Reset Now
echo                %green%2.%reset% Every 24 hours
echo                %green%3.%reset% Every 7 days
echo                %green%4.%reset% Every 15 days
echo                %green%5.%reset% Every 30 days
echo                %red%6. Remove Auto Schedule%reset%
echo.
set /p intervalChoice=Type your choice and hit Enter [1-6]: 

:: Handle Option 6: Remove scheduled task + cleanup
if /i "!intervalChoice!"=="6" (
    echo.
    echo %red%Removing scheduled task and cleaning up files...%reset%

    :: Remove scheduled task
    schtasks /query /tn "IDM Auto Reset" >nul 2>&1 && (
        schtasks /delete /tn "IDM Auto Reset" /f >nul 2>&1
        echo %green%Successfully removed scheduled task.%reset%
    ) || (
        echo %yellow%No scheduled task found.%reset%
    )

    :: Delete marker file
    if exist "%markerFile%" (
        del /f /q "%markerFile%" >nul 2>&1
        echo [%logDate%] Deleted marker file: %markerFile% >> "%logFile%"
        echo %green%Deleted marker file for future resets.%reset%
    ) else (
        echo [%logDate%] Marker file not found. Skipping. >> "%logFile%"
    )

    :: Delete log file
    if exist "%logFile%" (
        del /f /q "%logFile%" >nul 2>&1
        echo %green%Deleted log file: %logFile%.%reset%
    ) else (
        echo %yellow%Log file not found. Skipping.%reset%
    )

    echo.
    echo %green%Cleanup complete. IDM auto-reset has been fully removed.%reset%
    timeout /t 5 >nul
    exit /b
)

:: Map user input to seconds + schedule type
if /i "!intervalChoice!"=="1" (
    echo [%date% %time%] Manual reset triggered >> "%logFile%"
    echo    %green%Manual reset selected. Running now...%reset%
    goto MAIN_PROCESS
)
if /i "!intervalChoice!"=="2" (
    set intervalSec=86400
    set scheduleType=daily
    set scheduleMod=1
    call :GET_TIME scheduleTime
)
if /i "!intervalChoice!"=="3" (
    set intervalSec=604800
    set scheduleType=weekly
    set scheduleMod=1
    call :GET_TIME scheduleTime
)
if /i "!intervalChoice!"=="4" (
    set intervalSec=1296000
    set scheduleType=daily
    set scheduleMod=15
    call :GET_TIME scheduleTime
)
if /i "!intervalChoice!"=="5" (
    set intervalSec=2592000
    set scheduleType=monthly
    set scheduleMod=1
    call :GET_TIME scheduleTime
)

if not defined intervalSec (
    echo %red%Invalid choice.%reset% %green%Defaulting to 24 hours and time at 02:00AM.%reset%
    set intervalSec=86400
    set scheduleType=daily
    set scheduleMod=1
    set scheduleTime=02:00
)

:: Add to Task Scheduler
echo.
echo %cyan%Would you like to schedule automatic resets using Windows Task Scheduler?%reset%
echo %blue%This ensures the script runs in background based on your selected interval.%reset%
echo.
choice /c YN /n /m "Add to scheduled tasks? (Y/N): "
if errorlevel 2 goto SKIP_SCHEDULER
if errorlevel 1 (
    :: Remove existing task if exists
    schtasks /query /tn "IDM Auto Reset" >nul 2>&1 && (
        schtasks /delete /tn "IDM Auto Reset" /f >nul 2>&1
    )

    if /i "!scheduleType!"=="daily" (
        schtasks /create /tn "IDM Auto Reset" ^
            /tr "\"%cd%\%~nx0\" SILENT" ^
            /sc daily /mo !scheduleMod! /st !scheduleTime! ^
            /rl highest /f >nul 2>&1
    )

    if /i "!scheduleType!"=="weekly" (
        schtasks /create /tn "IDM Auto Reset" ^
            /tr "\"%cd%\%~nx0\" SILENT" ^
            /sc weekly /mo !scheduleMod! /d mon tue wed thu fri sat sun /st !scheduleTime! ^
            /rl highest /f >nul 2>&1
    )

    if /i "!scheduleType!"=="monthly" (
        schtasks /create /tn "IDM Auto Reset" ^
            /tr "\"%cd%\%~nx0\" SILENT" ^
            /sc monthly /mo on /dy !scheduleMod! /st !scheduleTime! ^
            /rl highest /f >nul 2>&1
    )

    if %errorlevel% neq 0 (
        echo %red%[!] Failed to create scheduled task. Try running as Administrator.%reset%
    ) else (
        echo %green%Added to Task Scheduler ^(runs every !scheduleMod! !scheduleType! at !scheduleTime!^).%reset%
    )
)

:SKIP_SCHEDULER
call :GET_TIMESTAMP markerNow
set /a nextReset=markerNow + intervalSec
for /f "tokens=*" %%T in ('powershell -Command "[timezone]::CurrentTimeZone.ToLocalTime([datetime]::ParseExact('!nextReset!','yyyyMMddHHmmss', $null))"') do set "nextResetFormatted=%%T"

echo.
echo Next scheduled reset: !nextResetFormatted!
echo %green%Setup complete! This script will now run automatically every !scheduleMod! !scheduleType!(s).%reset%
echo %blue%You may close this window now.%reset%
timeout /t 5 >nul
exit /b


:: =============
:: MAIN PROCESS
:: =============
:MAIN_PROCESS

:: Get clean log timestamp using PowerShell
set "logDate="
for /f "tokens=*" %%T in ('powershell -command "Get-Date -Format yyyy-MM-dd HH:mm:ss"') do set "logDate=%%T"

if defined logDate (
    for /f "tokens=1 delims=." %%a in ("!logDate!") do set "logDate=%%a"
)

:: Backup fallback if timestamp fails
if not defined logDate set "logDate=%date% %time%"


:: Start logging to file
echo Script Name: %scriptName% >> "%logFile%"
echo Computer Username: %username% >> "%logFile%"
echo Computer Hostname: %computername% >> "%logFile%"

:: Check if IDM is running
tasklist /FI "IMAGENAME eq IDMan.exe" 2>nul | findstr /I "IDMan.exe" >nul
if %errorlevel%==0 (
    set "wasRunning=1"
    echo [%logDate%] Closing currently running IDM... >> "%logFile%"
    taskkill /im IDMan.exe /f >nul 2>&1
) else (
    set "wasRunning=0"
    echo [%logDate%] IDM was not running. Proceeding with reset... >> "%logFile%"
)

:: Remove AppData folder first (safe operation)
if exist "%APPDATA%\IDM" (
    echo [%logDate%] Deleting folder: %APPDATA%\IDM >> "%logFile%"
    rd /s /q "%APPDATA%\IDM" >nul 2>&1
    if !errorlevel! == 0 (
        echo [%logDate%] Successfully deleted folder: %APPDATA%\IDM >> "%logFile%"
    ) else (
        echo [%logDate%] FAILED to delete folder: %APPDATA%\IDM >> "%logFile%"
    )
) else (
    echo [%logDate%] Folder not found: %APPDATA%\IDM >> "%logFile%"
)

:: Log start
echo [%logDate%] Starting registry cleanup... >> "%logFile%"

:: Loop through each root and delete registry keys
for %%R in (%ROOT_LIST%) do (
    set /a deleted=0
    echo [%logDate%] Checking %%R CLSID keys... >> "%logFile%"
    for %%C in (%CLSID_LIST%) do (
        for %%N in (%NODE_LIST%) do (
            if "%%N"=="" (
                set "fullKey=%%R\Software\Classes\CLSID\%%C"
            ) else (
                set "fullKey=%%R\Software\Classes\%%N\CLSID\%%C"
            )
            reg query !fullKey! >nul 2>&1 && (
                echo [%logDate%] Found key: !fullKey! >> "%logFile%"
                reg delete "!fullKey!" /f >nul 2>&1
                if !errorlevel! == 0 (
                    set /a deleted+=1
                    echo [%logDate%] Deleted key: !fullKey! >> "%logFile%"
                ) else (
                    echo [%logDate%] FAILED to delete key: !fullKey! >> "%logFile%"
                )
            ) || (
                echo [%logDate%] Key not found: !fullKey! >> "%logFile%"
            )
        )
    )
    echo [%logDate%] Total %%R CLSID keys deleted: !deleted! >> "%logFile%"
)

:: Delete IDM-specific keys
set /a idmDeleted=0
echo [%logDate%] Checking IDM registry paths... >> "%logFile%"
for %%I in (%IDM_PATHS%) do (
    reg query %%I >nul 2>&1 && (
        echo [%logDate%] Found IDM key: %%I >> "%logFile%"
        reg delete %%I /f >nul 2>&1
        if !errorlevel! == 0 (
            set /a idmDeleted+=1
            echo [%logDate%] Deleted IDM key: %%I >> "%logFile%"
        ) else (
            echo [%logDate%] FAILED to delete IDM key: %%I >> "%logFile%"
        )
    ) || (
        echo [%logDate%] Key not found: %%I >> "%logFile%"
    )
)
echo [%logDate%] Total IDM-specific keys deleted: !idmDeleted! >> "%logFile%"

:: Create marker file
echo [%logDate%] Creating marker file at: %markerFile% >> "%logFile%"
echo Reset performed at: %logDate% > "%markerFile%"

:: Always try to restart IDM after reset
set "idmStarted=0"
set "idmPath=%ProgramFiles%\Internet Download Manager\IDMan.exe"

echo [%logDate%] Attempting to restart Internet Download Manager >> "%logFile%"

:: Try Program Files path
if exist "!idmPath!" (
    echo [%logDate%] Starting IDM from: !idmPath! >> "%logFile%"
    start "" "!idmPath!" && set idmStarted=1
) else (
    echo [%logDate%] IDMan.exe NOT FOUND in: !idmPath! >> "%logFile%"
)

:: If not started yet, try Program Files (x86)
if "!idmStarted!"=="0" (
    set "idmPath=%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe"
    if exist "!idmPath!" (
        echo [%logDate%] Starting IDM from: !idmPath! >> "%logFile%"
        start "" "!idmPath!" && set idmStarted=1
    ) else (
        echo [%logDate%] IDMan.exe NOT FOUND in: !idmPath! >> "%logFile%"
    )
)

:: Final result
if "!idmStarted!"=="1" (
    echo [%logDate%] IDM.exe successfully restarted. >> "%logFile%"
) else (
    echo [%logDate%] Failed to restart IDM. Please start it manually. >> "%logFile%"
)

:: Notification (fixed!)
set "notifyMessage="
if "!idmStarted!"=="1" (
    set "notifyMessage=IDM has been reset and restarted!"
) else (
    set "notifyMessage=Reset completed, but IDM was not restarted."
)

:: Show balloon notification only if GUI available
PowerShell -Command ^
$ErrorActionPreference = 'SilentlyContinue'; ^
Add-Type -AssemblyName System.Windows.Forms; ^
$notify = New-Object System.Windows.Forms.NotifyIcon; ^
$notify.Icon = [System.Drawing.SystemIcons]::Information; ^
$notify.BalloonTipTitle = 'IDM Auto Reset Tool v%version%'; ^
$notify.BalloonTipText = '%notifyMessage%'; ^
$notify.Visible = $true; ^
$notify.ShowBalloonTip(10,'%scriptName% v%version% by %author%','!notifyMessage!', 'Info'); ^
Start-Sleep -Seconds 6; ^
$notify.Dispose();

:: Final log
echo [%logDate%] Reset Complete and IDM.exe restarted. >> "%logFile%"
echo. >> "%logFile%"

:: User feedback
if /i "%~1"=="SILENT" (
    echo.
    echo %blue%Background reset completed. You can close this window.%reset%
) else (
    echo.
    echo %green%Manual reset complete. You can close this window now.%reset%
)

timeout /t 5 >nul
exit /b


:: =========================
:: Helper Functions
:: =========================

:: Gets current time in yyyMMddHHmmss format
:GET_TIMESTAMP
setlocal
set "input=%~2"
if not defined input (
    for /f "tokens=*" %%T in ('powershell -command "Get-Date -Format yyyyMMddHHmmss"') do set "output=%%T"
) else (
    echo "%input%" | findstr [0-9][0-9]* >nul && (
        powershell -command "[datetime]::Parse('%input%', 'HH:mm', $null).Ticks" >nul 2>&1 && (
            set "output=%%T"
        )
    ) || (
        set "output=0"
    )
)
endlocal & set "%1=%output%" & exit /b

:: Validates and gets time from user input
:GET_TIME
:GET_TIME_INPUT
set /p %1=Enter preferred reset time (HH:MM): 
echo "%~1" | findstr /r "^\"[01][0-9]:[0-5][0-9]\"$" >nul || (
    echo %red%Invalid time format. Use HH:MM (e.g., 02:00 or 14:00).%reset%
    goto GET_TIME_INPUT
)
exit /b
