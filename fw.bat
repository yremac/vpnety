@echo off
setlocal enabledelayedexpansion

REM серкрк привет

REM Код обновления
set "repoURL=https://raw.githubusercontent.com/yremac/vpnety/main/fw.bat" 
set "scriptName=fw.bat"
set "tempFile=%temp%\updateScript.bat"

echo Проверка обновлений...

curl -s -o %tempFile% %repoURL%

fc /b %0 %tempFile% > nul

if errorlevel 1 (
  echo Новая версия скрипта найдена. Обновление...
  move /y %tempFile% %0
  echo Обновление завершено.
  goto :mainMenu
) else (
  echo Скрипт обновлен до последней версии.
)

REM Создание папки для установки во временной директории пользователя
set "tempDir=%USERPROFILE%\AppData\Local\Temp\HiddifyInstall"
mkdir "%tempDir%"

REM Проверка на успешное создание папки
if not exist "%tempDir%" (
    echo Error: Unable to create installation directory.
    pause
    goto mainMenu
)

:mainMenu
cls
echo.
echo ===============================
echo VPNety Setup KillSwitch Firewall
echo ===============================
echo.
echo Choose a command:
echo 1. Reset KillSwitch (reset firewall settings)
echo 2. Enable KillSwitch (reset firewall and block inbound and outbound connections)
echo 3. Add a program for inbound and outbound connections
echo 4. Install Hiddify from GitHub
echo 5. Settins for Hiddify
echo 6. Exit the script
echo 7. UNInstall Hiddify from GitHub
echo 8. clear Hiddify from GitHub
echo.

set /p "choice=Enter the command number: "

if "%choice%"=="1" (
    cls
    echo Resetting KillSwitch...
    echo Executing command: netsh advfirewall reset
    netsh advfirewall reset
    echo All OK
    pause
    goto mainMenu
)

if "%choice%"=="2" (
    cls
    echo Enabling KillSwitch...
    echo Executing command: netsh advfirewall reset
    netsh advfirewall reset
    echo All OK
    echo.
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
    rem Удаление возможных кавычек в начале и конце строки
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

if "%choice%"=="4" (
    cls
    echo Installing Hiddify from GitHub...
    set "tempDir=%USERPROFILE%\AppData\Local\Temp\HiddifyInstall"
    mkdir "%tempDir%"

    REM Проверка на успешное создание папки
    if not exist "%tempDir%" (
        echo Error: Unable to create installation directory.
        pause
        goto mainMenu
    )

    REM Скачивание Hiddify
    echo Downloading Hiddify...
    powershell -command "& { Invoke-WebRequest -Uri 'https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-windows-x64-setup.zip' -OutFile '!tempDir!\hiddify-windows-x64-setup.zip' }"

    REM Проверка наличия файла перед расспаковкой
    if not exist "!tempDir!\hiddify-windows-x64-setup.zip" (
        echo Error: Hiddify installation file not found.
        pause
        goto cleanup
    )

    REM Расспаковка Hiddify
    echo Extracting Hiddify...
    powershell -command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('!tempDir!\hiddify-windows-x64-setup.zip', '!tempDir!');}"

    REM Установка Hiddify
    echo Installing Hiddify silently...
    pushd "!tempDir!"
    start /wait setup.exe /S   REM Попробуйте также /VERYSILENT или другие флаги, зависящие от установщика
    popd

    REM Очистка временных файлов
    :cleanup
    echo Cleaning up...
    del "!tempDir!\hiddify-windows-x64-setup.zip"
    rmdir /s /q "!tempDir!"

    echo Hiddify installation complete.
    pause
    goto mainMenu
)

if "%choice%"=="5" (
    cls
    set "prefsFile=%APPDATA%\Hiddify\hiddify\shared_preferences.json"

    REM Создание директории, если её нет
    if not exist "%APPDATA%\Hiddify\hiddify" mkdir "%APPDATA%\Hiddify\hiddify"

    REM Создание файла shared_preferences.json в нужной директории
    echo {"flutter.preferences_version":1,"flutter.enable_analytics":false,"flutter.intro_completed":true,"flutter.profiles_update_check":"2023-12-24T19:07:35.963261","flutter.service-mode":"vpn","flutter.started_by_user":false,"flutter.locale":"ru"} > "!prefsFile!"

    echo Preferences file created successfully.
    pause
    goto mainMenu
)




if "%choice%"=="6" (
    echo Exiting the script.
    exit /b
)

if "%choice%"=="7" (
    cls
    set "installDir="
    set "appDataDir=%APPDATA%\Hiddify"

    REM Поиск расположения Program Files
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
        goto mainMenu
    )

    echo Hiddify is installed in: %installDir%

    set /p "confirm=Are you sure you want to uninstall Hiddify? (y/n): "
    if /i "%confirm%"=="y" (
        echo Uninstalling Hiddify...

        REM Удаление основной программы
        if exist "%installDir%\unins000.exe" (
            "%installDir%\unins000.exe" && (
                echo Hiddify successfully uninstalled.
            ) || (
                echo Error: Uninstallation process cancelled.
            )
        ) else (
            echo Uninstaller not found. Make sure Hiddify is installed.
        )
    ) else (
        echo Uninstall cancelled.
    )

    pause
    goto mainMenu
)

if "%choice%"=="8" (
    cls
    set "appDataDir=%APPDATA%\Hiddify"

    REM Проверка существования рабочей папки текущего пользователя
    if exist "%appDataDir%" (
        echo Hiddify configuration folder is located in: %appDataDir%
        set /p "deleteAppData=Do you want to delete the configuration folder as well? (y/n): "
        set "deleteAppData=%deleteAppData:~0,1%"  REM Extract the first character (user input)

        if /i "%deleteAppData%"=="y" (
            rmdir /s /q "%appDataDir%"
            echo Configuration folder deleted.
        ) else (
            echo Configuration folder preserved.
        )
    ) else (
        echo Hiddify configuration folder not found.
    )

    pause
    goto mainMenu
)





echo Invalid input. Please try again.
pause
goto mainMenu
