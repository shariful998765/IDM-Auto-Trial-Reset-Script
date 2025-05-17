@echo off
setlocal enabledelayedexpansion

:: Title
title IDM Auto Reset with Startup

:: ========================================================
:: Enhanced IDM Auto Reset Script
:: Automatically resets Internet Download Manager trial period
:: Version 2.2 - Improved logging, colors, and structure
:: ========================================================

:: Define ANSI color codes
set "black=[30m"
set "red=[31m"
set "green=[32m"
set "yellow=[33m"
set "blue=[34m"
set "magenta=[35m"
set "cyan=[36m"
set "white=[37m"
set "reset=[0m"

:: Log file path
set "logFile=%~dp0%~n0.log"

:: Check if already running in silent mode
if /i "%~1"=="SILENT" goto MAIN_PROCESS

:: If not running silently, create VBS launcher for background execution
set "batPath=%~f0"
set "vbsPath=%temp%\idm_reset_launcher.vbs"

echo Set WshShell = CreateObject("WScript.Shell") > "%vbsPath%"
echo WshShell.Run chr(34) ^& "%batPath%" ^& " SILENT" ^& Chr(34), 0 >> "%vbsPath%"
echo Set WshShell = Nothing >> "%vbsPath%"

:: Add to startup if not already there
call :ADD_TO_STARTUP

:: Launch the silent process and close this visible window
cscript //nologo "%vbsPath%" >nul 2>&1
if exist "%vbsPath%" del /q "%vbsPath%" >nul 2>&1
exit

:: =====================================================================
:: Main Process Starts Here
:: =====================================================================

:MAIN_PROCESS
call :log success "IDM Auto Reset started"

:: Create marker file path
set "markerFile=%temp%\idm_reset_marker"

:LOOP
:: Check if IDM is running
tasklist /FI "IMAGENAME eq IDMan.exe" 2>nul | find /I "IDMan.exe" >nul
if %ERRORLEVEL%==0 (
    call :log info "IDM detected running"
    timeout /t 30 /nobreak >nul
    goto LOOP
)

:: Check if we've recently reset (within last 5 minutes)
if exist "%markerFile%" (
    call :GET_TIMESTAMP now
    for %%F in ("%markerFile%") do set fileTime=%%~tF
    call :GET_TIMESTAMP file "%fileTime%"

    set /a diffSec=(%now% - %file%)
    if %diffSec% LSS 300 (
        call :log warn "Reset skipped: Already done within last 5 minutes (%diffSec% sec ago)"
        timeout /t 60 /nobreak >nul
        goto LOOP
    )
)

:: IDM not running and no recent reset - perform reset operations
call :log warn "Performing IDM reset"

:: Create/update marker file
echo Reset performed at %date% %time% > "%markerFile%"

:: Delete registry entries
reg delete "HKCU\Software\DownloadManager" /f >nul 2>&1 || call :log error "Failed to delete HKCU\Software\DownloadManager"
reg delete "HKCU\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}" /f >nul 2>&1 || call :log error "Failed to delete CLSID key"
reg delete "HKCU\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}" /f >nul 2>&1 || call :log error "Failed to delete Wow6432Node CLSID key"
reg delete "HKLM\SOFTWARE\Internet Download Manager" /f >nul 2>&1 || call :log error "Failed to delete HKLM\SOFTWARE\Internet Download Manager"
reg delete "HKLM\SOFTWARE\Wow6432Node\Internet Download Manager" /f >nul 2>&1 || call :log error "Failed to delete HKLM\Wow6432Node key"

:: Delete AppData folder if exists
if exist "%APPDATA%\IDM" (
    rd /S /Q "%APPDATA%\IDM" >nul 2>&1 && (
        call :log success "Deleted AppData\IDM folder"
    ) || (
        call :log error "Failed to delete AppData\IDM folder"
    )
)

:: Optional cleanup (cookies - only if needed)
if exist "%USERPROFILE%\Cookies\*idm*" del /q "%USERPROFILE%\Cookies\*idm*" >nul 2>&1
if exist "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCookies\*idm*" del /q "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCookies\*idm*" >nul 2>&1

call :log success "Reset completed successfully"
echo. >> "%logFile%"

:: Wait before looping back
timeout /t 60 /nobreak >nul
goto LOOP


:: ========================================================
:: Subroutines
:: ========================================================

:ADD_TO_STARTUP
:: Add script to startup folder if not already there
set "startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "startupShortcut=%startupFolder%\idm_auto_trial_reset.bat"

if not exist "%startupShortcut%" (
    copy "%~f0" "%startupShortcut%" >nul 2>&1 && (
        call :log success "Added to startup"
    ) || (
        call :log error "Failed to add to startup"
    )
)
exit /b


:: Converts date/time to seconds since epoch
:: Usage: call :GET_TIMESTAMP resultVar ["YYYY-MM-DD HH:MM"]
:GET_TIMESTAMP
setlocal
set "input=%~2"
if not defined input for /f "tokens=2 delims==." %%R in ('wmic os get localdatetime /value') do set "input=%%R"
set "YYYY=%input:~0,4%"
set "MM=%input:~4,2%"
set "DD=%input:~6,2%"
set "HH=%input:~8,2%"
set "Min=%input:~10,2%"
set "SS=%input:~12,2%"

:: Convert to Julian day
set /a a=10000%MM% - 10000101, a/=100, m=MM+9, m%%=12, y=YYYY - m/10
set /a jd= (1461 * y) / 4 + (153 * m + 2)/5 + DD - 694039 + 2440588 - 2415021

:: Seconds since epoch
set /a totalSec= !jd! * 86400 + (1!HH! - 100)*3600 + 1!Min! * 60 - 6000 + 1!SS! - 100
endlocal & set "%1=%totalSec%"
exit /b


:: Unified logging function
:: Usage: call :log [level] [message]
:log
set "type=%~1"
set "msg=%~2"

if /i "%type%"=="info" (
    echo %blue%[INFO]%reset% %msg%
    echo [INFO] %msg% >> "%logFile%"
) else if /i "%type%"=="warn" (
    echo %yellow%[WARNING]%reset% %msg%
    echo [WARNING] %msg% >> "%logFile%"
) else if /i "%type%"=="error" (
    echo %red%[ERROR]%reset% %msg%
    echo [ERROR] %msg% >> "%logFile%"
) else if /i "%type%"=="success" (
    echo %green%[SUCCESS]%reset% %msg%
    echo [SUCCESS] %msg% >> "%logFile%"
)
exit /b