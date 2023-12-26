@echo off
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
  goto :mainMenu
) else (
  echo Script is up to date.
)

set RULE_BASE_NAME=BlockOutgoing
set INTERFACE_ALLOWED=tun0

:menu
cls
echo VPNety killSwitch Firewall Control Menu

echo 1. Activate killSwitch rules
echo 2. Deactivate killSwitch rules

set /p choice=Chose action (1-2): 

if "%choice%"=="1" (
    call :enableFirewallRules
) else if "%choice%"=="2" (
    call :disableFirewallRules
) else if "%choice%"=="3" (
    exit /b
) else (
    echo Invalid input.  Please select 1 or 2.
    timeout /nobreak /t 3 >nul
    goto :menu
)

:enableFirewallRules
echo Enabling rules...

:: Получаем список интерфейсов и создаем правила
for /f "tokens=*" %%I in ('powershell -Command "Get-NetAdapter | Where-Object { $_.InterfaceAlias -ne '!INTERFACE_ALLOWED!' } | ForEach-Object { $_.InterfaceAlias }"') do (
    powershell -Command "New-NetFirewallRule -DisplayName '%RULE_BASE_NAME%_%%I' -Direction Outbound -Action Block -InterfaceAlias '%%I'" >nul 2>&1
    echo The rule for interface %%I is enabled.
)

echo All rules included.
timeout /nobreak /t 3 >nul
goto :menu

:disableFirewallRules
echo Disabling rules...

:: Получаем список интерфейсов и удаляем правила
for /f "tokens=*" %%I in ('powershell -Command "Get-NetAdapter | Where-Object { $_.InterfaceAlias -ne '!INTERFACE_ALLOWED!' } | ForEach-Object { $_.InterfaceAlias }"') do (
    powershell -Command "Remove-NetFirewallRule -DisplayName '%RULE_BASE_NAME%_%%I'" 2>nul
    echo The rule for interface %%I is disabled.
)

echo All rules are disabled.
timeout /nobreak /t 3 >nul
goto :menu
