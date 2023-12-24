@echo off
setlocal enabledelayedexpansion

REM Check if the script is run with administrator privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM If not run with administrator privileges, restart with a request for elevation
if "%errorlevel%" neq "0" (
    echo Running the script requires administrator privileges. Restarting with a request for elevation...
    powershell -command "& {Start-Process '%0' -Verb RunAs}"
    exit /b
)

REM Update Code
set "repoURL=https://github.com/yremac/vpnety"
set "scriptName=fw.bat"
set "tempFile=%temp%\updateScript.bat"

echo Checking for updates...

certutil -urlcache -split -f %repoURL%/raw/main/%scriptName% %tempFile%

REM Use FC command to compare the files
fc /b %0 %tempFile% > nul

if errorlevel 1 (
    echo New version of the script found. Updating...
    move /y %tempFile% %0
    echo Update completed.
) else (
    echo Script is up to date.
)

:mainMenu
cls
echo.
echo ===============================
echo VPNety Setup KillSwitch Firewall
echo ===============================
echo.
echo Choose a command:
echo 1. Reset firewall settings to default
echo.

set /p "choice=Enter the command number: "

if "%choice%"=="1" (
    cls
    echo Executing command: netsh advfirewall reset
    netsh advfirewall reset
    echo All OK
    pause
    goto mainMenu
)

if "%choice%"=="2" (
    cls
    echo Executing command: netsh advfirewall set domainprofile firewallpolicy blockinbound,blockoutbound
    netsh advfirewall set domainprofile firewallpolicy blockinbound,blockoutbound
    echo All OK
    echo.
    echo Executing command: netsh advfirewall set privateprofile firewallpolicy blockinbound,blockoutbound
    netsh advfirewall set privateprofile firewallpolicy blockinbound,blockoutbound
    echo All OK
    pause
    goto mainMenu
)

if "%choice%"=="3" (
    cls
    set "counter=1"
    :addProgramLoop
    echo.
    set /p "programPath=Enter the path for program %counter% for inbound and outbound connections: "
    rem Remove any potential quotes at the beginning and end of the string
    set "programPath=!programPath:"=!"
    echo Adding rule for inbound and outbound program: "!programPath!"
    netsh advfirewall firewall add rule name="VPNety KillSwitch Firewall - Program %counter%" dir=in program="!programPath!" action=allow enable=yes profile=domain,private,public
    netsh advfirewall firewall add rule name="VPNety KillSwitch Firewall - Program %counter%" dir=out program="!programPath!" action=allow enable=yes profile=domain,private,public
    echo All OK
    set /p "addMore=Add another program? (y/n): "
    if /i "!addMore!"=="y" (
        set /a "counter+=1"
        goto addProgramLoop
    )
    pause
    goto mainMenu
)

if "%choice%"=="4" goto mainMenu

if "%choice%"=="5" (
    echo Exiting the script.
    exit /b
)

echo Invalid input. Please try again.
pause
goto mainMenu
