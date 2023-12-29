@echo off
setlocal

:: Установка пути для конфигурационного файла
set "configPath=%APPDATA%\YogaDNS\Configuration.xml"

:: Путь к папке для конфигурации
set "configFolder=%APPDATA%\YogaDNS"

:: Путь к установленной программе
set "programPath=C:\Program Files (x86)\YogaDNS"

:: URL для скачивания установщика
set "installerURL=https://yogadns.com/download/YogaDNSSetup.exe"

:: Имя временного файла для установщика
set "tempInstaller=%TEMP%\YogaDNSSetup.exe"

:: Создаем папку для конфигурации, если её нет
if not exist "%configFolder%" mkdir "%configFolder%"

:: Скачиваем установщик
echo Скачивание установщика YogaDNS...
curl -o "%tempInstaller%" "%installerURL%"

:: Проверяем успешность загрузки установщика
if %errorlevel% neq 0 (
    echo Ошибка при скачивании установщика YogaDNS.
    exit /b 1
)

:: Устанавливаем программу в фоновом режиме
echo Установка YogaDNS...
pushd "%configFolder%"
call "%tempInstaller%" /VERYSILENT
popd

:: Проверяем, была ли установка успешной
if %errorlevel% neq 0 (
    echo Ошибка при установке YogaDNS.
    exit /b 1
)

:: Создаем конфигурационный файл
echo ^<?xml version="1.0" encoding="UTF-8" standalone="yes"^?^> > "%configPath%"
echo ^<YogaDnsProfile file_format="1" product_id="1" product_min_version="127000"^> >> "%configPath%"
echo    ^<Settings ignore_rule_if_interface_down="1" blockTcpPort53="1" clearDnsCache="1" ttlMin="0" ttlMax="2147483647" captivePortalDetection="0" interceptOthers="0"^> >> "%configPath%"
echo        ^<DnsChecker testTarget="iana.org" testsPerTime="15" importUrls="https://yogadns.com/resolvers/resolvers.md https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/relays.md"^ /^> >> "%configPath%"
echo    ^</Settings^> >> "%configPath%"
echo    ^<Rule name="Mullvad DNS to VPNety" enabled="1" dnssec_local_validation="0" dnssec_reject_unsigned="0" hostnames="*" action="process_server" action_id="2139" interface_id="{0DCCC63E-5622-3880-1E09-7CC9C46AD7B4}" interface_id_type="id" interface_name="tun0" /^> >> "%configPath%"
echo    ^<Rule name="Default" enabled="1" dnssec_local_validation="0" dnssec_reject_unsigned="0" hostnames="*" action="process_server" action_id="1762" interface_id="" interface_id_type="id" interface_name="" /^> >> "%configPath%"
echo    ^<DnsServer id="2281" name="Cloudflare Plain" protocol="plain" af="2" ip="1.1.1.1" dnssec_supported="1" plain_use_tcp="0" /^> >> "%configPath%"
echo    ^<DnsServer id="1001" name="Quad9 DNSCrypt" port="8443" protocol="dnscrypt" af="2" ip="9.9.9.10" dnssec_supported="1" dnscrypt_provider_name="2.dnscrypt-cert.quad9.net" dnscrypt_public_key="67C8:47B8:C875:8CD1:2024:5543:BE75:6746:DF34:DF1D:84C0:0B8C:4703:68DF:821D:863E" dnscrypt_disable_padding="1" dnscrypt_force_tcp="0" /^> >> "%configPath%"
echo    ^<DnsServer id="2139" name="mullvad-base-doh" protocol="doh" af="2" ip="194.242.2.4" dnssec_supported="1" doh_host_name="base.dns.mullvad.net" doh_path="/dns-query" /^> >> "%configPath%"
echo    ^<DnsServer id="1762" name="quad9-doh-ip4-port443-filter-pri" protocol="doh" af="2" ip="9.9.9.9" dnssec_supported="1" doh_host_name="dns9.quad9.net" doh_path="/dns-query" doh_hashes="2A15:F5D6:ACB6:E7C0:901A:DE4E:BBC7:43B2:CCD4:8903:2B46:E164:2F06:9368:3001:258A" /^> >> "%configPath%"
echo ^</YogaDnsProfile^> >> "%configPath%"

:: Выводим сообщение об успешной установке
echo "YogaDNS успешно установлен и настроен."

:: Запускаем программу
start "" "%programPath%\YogaDNS.exe"

endlocal
