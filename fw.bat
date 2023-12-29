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
echo VPNety help VPN Setup
echo ===============================
echo.
echo Choose a command:
echo 1. Install and configure Hiddify VPN software from GitHub
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
echo =============================================
echo Install and Configure Hiddify VPN software
echo =============================================
echo.
echo Choose a command:
echo 1. Install Hiddify VPN software from GitHub
echo 2. Configure Hiddify (Run after installation!)
echo =============================================
echo 3. Uninstall Hiddify from the PC
echo 4. Clear the Hiddify working folder on the PC
echo 5. Return to the main menu
echo.

set /p "hiddifyChoice=Enter the command number for Hiddify:"

if "%hiddifyChoice%"=="1" (
    cls
    echo Installing Hiddify from GitHub...
    set "tempDir=%USERPROFILE%\AppData\Local\Temp\HiddifyInstall"
    mkdir "%tempDir%"

    REM Check for successful creation of the installation folder
    if not exist "%tempDir%" (
        echo Error: Unable to create the installation directory.
        pause
        goto hiddifyMenu
    )

    REM Download Hiddify
    echo Downloading Hiddify...
    curl -o "%tempDir%\hiddify-windows-x64-setup.zip" -L "https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-windows-x64-setup.zip"

    REM Check for the file before extraction
    if not exist "%tempDir%\hiddify-windows-x64-setup.zip" (
        echo Error: Hiddify installation file not found.
        pause
        goto cleanup
    )

    REM Extract Hiddify
    echo Extracting Hiddify...
    powershell -command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('!tempDir!\hiddify-windows-x64-setup.zip', '!tempDir!');}"

	REM Install Hiddify
	echo Installing Hiddify silently...
	pushd "%tempDir%"

	REM Search for any .exe file in the directory
	for %%I in (*.exe) do (
		start /wait %%I /S   REM You may also try /VERYSILENT or other flags depending on the installer
		goto :found
	)

	REM If no .exe file is found
	echo Error: No executable file found for installation.
	pause
	goto cleanup

	:found
	popd


    REM Clean up temporary files
    :cleanup
    echo Cleaning up...
    del "!tempDir!\hiddify-windows-x64-setup.zip"
    rmdir /s /q "!tempDir!"

    echo Hiddify installation completed.
    pause
    goto hiddifyMenu
)

if "%hiddifyChoice%"=="2" (
    cls
    set "prefsFile=%APPDATA%\Hiddify\hiddify\shared_preferences.json"

    REM Create the directory if it doesn't exist
    if not exist "%APPDATA%\Hiddify\hiddify" mkdir "%APPDATA%\Hiddify\hiddify"

    REM Create the shared_preferences.json file in the required directory
    echo {"flutter.preferences_version":1,"flutter.enable_analytics":false,"flutter.intro_completed":true,"flutter.profiles_update_check":"2023-12-29T11:02:16.913851","flutter.service-mode":"vpn","flutter.started_by_user":true,"flutter.locale":"ru","flutter.remote-dns-address":"https://base.dns.mullvad.net/dns-query"} > "!prefsFile!"

    echo Settings file created successfully.
    pause
    goto hiddifyMenu
)

if "%hiddifyChoice%"=="3" (
    cls
    set "installDir="
    set "appDataDir=%APPDATA%\Hiddify"

    REM Search for the location of Program Files
    for /d %%D in ("%ProgramFiles%\Hiddify" "%ProgramFiles(x86)%\Hiddify") do (
        if exist "%%~D\unins000.exe" (
            set "installDir=%%~D"
            goto FoundInstallDir
        )
    )

    :FoundInstallDir
    if not defined installDir (
        echo Error: Hiddify is not installed.
        pause
        goto hiddifyMenu
    )

    echo Hiddify is installed in: %installDir%

    set /p "confirm=Are you sure you want to uninstall Hiddify? (y/n): "
    if /i "%confirm%"=="y" (
        echo Uninstalling Hiddify...

        REM Remove the main program
        if exist "%installDir%\unins000.exe" (
            "%installDir%\unins000.exe" && (
                echo Hiddify successfully removed.
            ) || (
                echo Error: Uninstallation process canceled.
            )
        ) else (
            echo Uninstaller not found. Make sure Hiddify is installed.
        )
    ) else (
        echo Uninstallation canceled.
    )

    pause
    goto hiddifyMenu
)

REM Insert PowerShell code block to remove Hiddify
if "%hiddifyChoice%"=="4" (
    cls
    set "tempDir=%USERPROFILE%\AppData\Roaming\Hiddify"
    set "deleteConfig="

    REM Check for the presence of the Hiddify configuration folder
    if exist "%tempDir%" (
        echo Hiddify configuration folder is located at: %tempDir%
        set /p "deleteConfig=Do you want to also delete the folder with settings? (y/n): "

        if /i "%deleteConfig%"=="y" (
            echo Deleting the configuration folder...
            rmdir /s /q "%tempDir%"
            
            REM Check for the folder after deletion
            if exist "%tempDir%" (
                echo Error: Hiddify configuration folder not deleted.
            ) else (
                echo Hiddify configuration folder successfully deleted.
            )
        ) else (
            echo Configuration folder saved. Run this command again if needed!
        )
    ) else (
        echo Hiddify configuration folder not found.
    )

    pause
    goto hiddifyMenu
)

if "%hiddifyChoice%"=="5" (
    goto mainMenu
)

echo Invalid input. Please try again.
pause
goto hiddifyMenu
