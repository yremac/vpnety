@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM Update Code
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

echo 1. Включить killSwitch правила
echo 2. Выключить killSwitch правила

set /p choice=Выберите действие (1-2): 

if "%choice%"=="1" (
    call :enableFirewallRules
) else if "%choice%"=="2" (
    call :disableFirewallRules
) else if "%choice%"=="3" (
    exit /b
) else (
    echo Некорректный ввод. Пожалуйста, выберите 1 или 2.
    timeout /nobreak /t 3 >nul
    goto :menu
)

:enableFirewallRules
echo Включение правил...

:: Получаем список интерфейсов и создаем правила
for /f "tokens=*" %%I in ('powershell -Command "Get-NetAdapter | Where-Object { $_.InterfaceAlias -ne '!INTERFACE_ALLOWED!' } | ForEach-Object { $_.InterfaceAlias }"') do (
    powershell -Command "New-NetFirewallRule -DisplayName '%RULE_BASE_NAME%_%%I' -Direction Outbound -Action Block -InterfaceAlias '%%I'" >nul 2>&1
    echo Правило для интерфейса %%I включено.
)

echo Все правила включены.
timeout /nobreak /t 3 >nul
goto :menu

:disableFirewallRules
echo Выключение правил...

:: Получаем список интерфейсов и удаляем правила
for /f "tokens=*" %%I in ('powershell -Command "Get-NetAdapter | Where-Object { $_.InterfaceAlias -ne '!INTERFACE_ALLOWED!' } | ForEach-Object { $_.InterfaceAlias }"') do (
    powershell -Command "Remove-NetFirewallRule -DisplayName '%RULE_BASE_NAME%_%%I'" 2>nul
    echo Правило для интерфейса %%I выключено.
)

echo Все правила выключены.
timeout /nobreak /t 3 >nul
goto :menu
