@echo off
@chcp 65001 > nul
setlocal enabledelayedexpansion

REM Код обновления v2
set "repoURL=https://raw.githubusercontent.com/yremac/vpnety/main/fw.bat"
set "scriptName=fw.bat"
set "tempFile=%temp%\updateScript.bat"

echo Проверка обновлений...

powershell -command "& { Invoke-WebRequest -Uri '%repoURL%' -OutFile '%tempFile%' }"

fc /b %0 %tempFile% > nul

if %errorlevel% neq 0 (
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
    echo Ошибка: Невозможно создать каталог для установки.
    pause
    goto mainMenu
)

:mainMenu
cls
echo.
echo ===============================
echo VPNety Настройка KillSwitch Firewall
echo ===============================
echo.
echo Выберите команду:
echo 1. Сбросить KillSwitch (сбросить настройки брандмауэра)
echo 2. Включить KillSwitch (сбросить настройки брандмауэра и блокировать входящие и исходящие соединения)
echo 3. Добавить программу для входящих и исходящих соединений
echo 4. Установить и настроить Hiddify из GitHub
echo 5. Выйти из скрипта
echo.

set /p "choice=Введите номер команды: "

if "%choice%"=="1" (
    cls
    echo Сброс KillSwitch...
    echo Выполнение команды: netsh advfirewall reset
    netsh advfirewall reset
    echo Все ОК
    pause
    goto mainMenu
)

if "%choice%"=="2" (
    REM Получаем индекс активного сетевого подключения
    for /f "tokens=*" %%a in ('powershell -Command "Get-NetConnectionProfile ^| Where-Object { $_.OperationalStatus -eq 'Up' } ^| Select-Object -First 1 ^| Select-Object -ExpandProperty InterfaceIndex"') do set "interfaceIndex=%%a"

    REM Если найден индекс, меняем тип сети на частный
    if defined interfaceIndex (
        powershell -Command "Get-NetConnectionProfile -InterfaceIndex !interfaceIndex! | Set-NetConnectionProfile -NetworkCategory Private"
        echo Тип сети изменен на Частный (Private) для интерфейса с индексом !interfaceIndex!.
    ) else (
        echo Не удалось определить активное сетевое подключение.
        goto :mainMenu
    )

    cls
    echo Включение KillSwitch...
    echo Выполнение команды: netsh advfirewall reset
    netsh advfirewall reset
    echo Все ОК
    echo.
    echo Выполнение команды: netsh advfirewall set domainprofile firewallpolicy blockinbound,blockoutbound
    netsh advfirewall set domainprofile firewallpolicy blockinbound,blockoutbound
    echo Все ОК
    echo.
    echo Выполнение команды: netsh advfirewall set privateprofile firewallpolicy blockinbound,blockoutbound
    netsh advfirewall set privateprofile firewallpolicy blockinbound,blockoutbound
    echo Все ОК
    pause
    goto mainMenu
)



if "%choice%"=="3" (
    cls
    set "counter=1"
    :addProgramLoop
    echo.
    set /p "programPath=Введите путь для программы %counter% для входящих и исходящих соединений: "
    rem Удаление возможных кавычек в начале и конце строки
    set "programPath=!programPath:"=!"
    echo Добавление правила для входящих и исходящих программы: "!programPath!"
    netsh advfirewall firewall add rule name="VPNety KillSwitch Firewall - Программа %counter%" dir=in program="!programPath!" action=allow enable=yes profile=domain,private,public
    netsh advfirewall firewall add rule name="VPNety KillSwitch Firewall - Программа %counter%" dir=out program="!programPath!" action=allow enable=yes profile=domain,private,public
    echo Все ОК
    set /p "addMore=Добавить еще программу? (y/n): "
    if /i "!addMore!"=="y" (
        set /a "counter+=1"
        goto addProgramLoop
    )
    pause
    goto mainMenu
)

if "%choice%"=="4" (
    goto :hiddifyMenu
)

if "%choice%"=="5" (
    echo Выход из скрипта.
    exit /b
)

echo Неверный ввод. Пожалуйста, повторите попытку.
pause
goto mainMenu

:hiddifyMenu
cls
echo.
echo =====================
echo Установка и настройка Hiddify
echo =====================
echo.
echo Выберите команду:
echo 1. Установить Hiddify из GitHub
echo 2. Настроить Hiddify (Выполнить после установки!)
echo 3. Удалить Hiddify с ПК
echo 4. Очистить рабочую папку Hiddify на ПК
echo 5. Вернуться в главное меню
echo.

set /p "hiddifyChoice=Введите номер команды для Hiddify:"

if "%hiddifyChoice%"=="1" (
    cls
    echo Установка Hiddify из GitHub...
    set "tempDir=%USERPROFILE%\AppData\Local\Temp\HiddifyInstall"
    mkdir "%tempDir%"

    REM Проверка на успешное создание папки
    if not exist "%tempDir%" (
        echo Ошибка: Невозможно создать каталог для установки.
        pause
        goto hiddifyMenu
    )

    REM Скачивание Hiddify
    echo Загрузка Hiddify...
    powershell -command "& { Invoke-WebRequest -Uri 'https://github.com/hiddify/hiddify-next/releases/latest/download/hiddify-windows-x64-setup.zip' -OutFile '!tempDir!\hiddify-windows-x64-setup.zip' }"

    REM Проверка наличия файла перед расспаковкой
    if not exist "!tempDir!\hiddify-windows-x64-setup.zip" (
        echo Ошибка: Файл установки Hiddify не найден.
        pause
        goto cleanup
    )

    REM Расспаковка Hiddify
    echo Распаковка Hiddify...
    powershell -command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('!tempDir!\hiddify-windows-x64-setup.zip', '!tempDir!');}"

    REM Установка Hiddify
    echo Установка Hiddify молча...
    pushd "!tempDir!"
    start /wait setup.exe /S   REM Попробуйте также /VERYSILENT или другие флаги, зависящие от установщика
    popd

    REM Очистка временных файлов
    :cleanup
    echo Очистка...
    del "!tempDir!\hiddify-windows-x64-setup.zip"
    rmdir /s /q "!tempDir!"

    echo Установка Hiddify завершена.
    pause
    goto hiddifyMenu
)

if "%hiddifyChoice%"=="2" (
    cls
    set "prefsFile=%APPDATA%\Hiddify\hiddify\shared_preferences.json"

    REM Создание директории, если её нет
    if not exist "%APPDATA%\Hiddify\hiddify" mkdir "%APPDATA%\Hiddify\hiddify"

    REM Создание файла shared_preferences.json в нужной директории
    echo {"flutter.preferences_version":1,"flutter.enable_analytics":false,"flutter.intro_completed":true,"flutter.profiles_update_check":"2023-12-24T19:07:35.963261","flutter.service-mode":"vpn","flutter.started_by_user":false,"flutter.locale":"ru"} > "!prefsFile!"

    echo Файл настроек создан успешно.
    pause
    goto hiddifyMenu
)

if "%hiddifyChoice%"=="3" (
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
        echo Ошибка: Hiddify не установлен.
        pause
        goto hiddifyMenu
    )

    echo Hiddify установлен в: %installDir%

    set /p "confirm=Вы уверены, что хотите деинсталлировать Hiddify? (y/n): "
    if /i "%confirm%"=="y" (
        echo Деинсталляция Hiddify...

        REM Удаление основной программы
        if exist "%installDir%\unins000.exe" (
            "%installDir%\unins000.exe" && (
                echo Hiddify успешно удален.
            ) || (
                echo Ошибка: Процесс деинсталляции отменен.
            )
        ) else (
            echo Деинсталлятор не найден. Убедитесь, что Hiddify установлен.
        )
    ) else (
        echo Деинсталляция отменена.
    )

    pause
    goto hiddifyMenu
)

REM Вставляем блок PowerShell-кода для удаления Hiddify
if "%hiddifyChoice%"=="4" (
    cls
    set "tempDir=%USERPROFILE%\AppData\Roaming\Hiddify"
    set "deleteConfig="

    REM Проверка наличия папки конфигурации Hiddify
    if exist "%tempDir%" (
        echo Папка конфигурации Hiddify находится в: %tempDir%
        set /p "deleteConfig=Хотите удалить также папку с настройками? (y/n): "

        if /i "%deleteConfig%"=="y" (
            echo Папка конфигурации удалена.
            rmdir /s /q "%tempDir%"
            
            REM Проверка наличия папки после удаления
            if exist "%tempDir%" (
                echo Ошибка: Папка конфигурации Hiddify не удалена.
            ) else (
                echo Папка конфигурации Hiddify успешно удалена.
            )
        ) else (
            echo Папка конфигурации сохранена. Повторно выполните данную команду!
        )
    ) else (
        echo Папка конфигурации Hiddify не найдена.
    )

    pause
    goto hiddifyMenu
)



if "%hiddifyChoice%"=="5" (
    goto mainMenu
)

echo Неверный ввод. Пожалуйста, повторите попытку.
pause
goto hiddifyMenu
