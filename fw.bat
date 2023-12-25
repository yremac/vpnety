@echo off
setlocal enabledelayedexpansion

REM Update Code
set "repoURL=https://raw.githubusercontent.com/yremac/vpnety/main/fw.bat"
set "scriptName=fw.bat"
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

REM Creating a folder for installation in the user's temporary directory
set "tempDir=%USERPROFILE%\AppData\Local\Temp\HiddifyInstall"
mkdir "%tempDir%"

REM Checking for successful creation of the folder
if not exist "%tempDir%" (
    echo Error: Unable to create the installation directory.
    pause
    goto mainMenu
)

:mainMenu
cls
echo.
echo ===============================
echo VPNety KillSwitch Firewall Setup
echo ===============================
echo.
echo Choose a command:
echo 1. Install and configure Hiddify from GitHub
echo 2. Exit the script
echo.

set /p "choice=Enter the command number: "

if "%choice%"=="1" (
    goto :hiddifyMenu
)

if "%choice%"=="2" (
    echo Exiting the script.
    exit /b
)

echo Invalid input. Please try again.
pause
goto mainMenu

:hiddifyMenu
cls
echo.
echo =====================
echo Install and Configure Hiddify
echo =====================
echo.
echo Choose a command:
echo 1. Install Hiddify from GitHub
echo 2. Configure Hiddify (Run after installation!)
echo 3. Uninstall Hiddify from the PC
echo 4. Clear the Hiddify working folder on the PC
echo 5. Return to the main menu
echo.

set /p "hiddifyChoice=Enter the command number for Hiddify:"

if "%hiddifyChoice%"=="1" (
    REM Your installation code for Hiddify goes here...

)

if "%hiddifyChoice%"=="2" (
    REM Your configuration code for Hiddify goes here...

)

if "%hiddifyChoice%"=="3" (
    REM Your uninstallation code for Hiddify goes here...

)

if "%hiddifyChoice%"=="4" (
    REM Your code to clear the Hiddify working folder goes here...

)

if "%hiddifyChoice%"=="5" (
    goto mainMenu
)

echo Invalid input. Please try again.
pause
goto hiddifyMenu
