@echo off
:: Check if the script is running as administrator
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" && (
    goto :continue
) || (
    echo You must run this script as an administrator.
    echo Exiting...
    timeout /nobreak /t 6 >nul
    exit /b
)

:continue
chcp 65001 > nul
setlocal enabledelayedexpansion

REM Update Code 1
set "repoURL=https://raw.githubusercontent.com/yremac/vpnety/main/killSwitch.bat"
set "scriptName=killSwitch.bat"
set "tempFile=%temp%\updateScript.bat"

echo Checking for updates...

powershell -command "& { Invoke-WebRequest -Uri '%repoURL%' -OutFile '%tempFile%' }"

fc /b %0 %tempFile% > nul

if %errorlevel% neq 0 (
  echo New version of the script found. Updating...
  move /y %tempFile% %0
  echo Update completed.
) else (
  echo Script is up to date.
)

:mainMenu
@echo off
setlocal enabledelayedexpansion

set RULE_BASE_NAME=BlockOutgoing
set INTERFACE_ALLOWED=tun0

:menu
cls
echo VPNety KillSwitch Firewall Control Menu

echo 1. Enable KillSwitch Rules
echo 2. Disable KillSwitch Rules
echo 3. Check for Updates
echo 4. Exit

set /p choice=Choose an action (1-4): 

if "%choice%"=="1" (
    call :enableFirewallRules
) else if "%choice%"=="2" (
    call :disableFirewallRules
) else if "%choice%"=="3" (
    call :checkForUpdates
) else if "%choice%"=="4" (
    exit /b 0
) else (
    echo Invalid input. Please choose 1, 2, 3, or 4.
    timeout /nobreak /t 3 >nul
    goto :menu
)

:enableFirewallRules
echo Enabling rules...

:: Get the list of interfaces and create rules
for /f "tokens=*" %%I in ('powershell -Command "Get-NetAdapter | Where-Object { $_.InterfaceAlias -ne '!INTERFACE_ALLOWED!' } | ForEach-Object { $_.InterfaceAlias }"') do (
    powershell -Command "New-NetFirewallRule -DisplayName '%RULE_BASE_NAME%_%%I' -Direction Outbound -Action Block -InterfaceAlias '%%I'" >nul 2>&1
    echo Rule for interface %%I enabled.
)

echo All rules are enabled.
timeout /nobreak /t 3 >nul
goto :menu

:disableFirewallRules
echo Disabling rules...

:: Get the list of interfaces and remove rules
for /f "tokens=*" %%I in ('powershell -Command "Get-NetAdapter | Where-Object { $_.InterfaceAlias -ne '!INTERFACE_ALLOWED!' } | ForEach-Object { $_.InterfaceAlias }"') do (
    powershell -Command "Remove-NetFirewallRule -DisplayName '%RULE_BASE_NAME%_%%I'" 2>nul
    echo Rule for interface %%I disabled.
)

echo All rules are disabled.
timeout /nobreak /t 3 >nul
goto :menu

:checkForUpdates
REM Update Code 2
echo Checking for updates...

powershell -command "& { Invoke-WebRequest -Uri '%repoURL%' -OutFile '%tempFile%' }"

fc /b %0 %tempFile% > nul

if %errorlevel% neq 0 (
  echo New version of the script found. Updating...
  move /y %tempFile% %0
  echo Update completed.
  goto :mainMenu
) else (
  echo Script is up to date.
)

timeout /nobreak /t 3 >nul
goto :menu
