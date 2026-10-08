@echo off
chcp 65001 >nul
title Меню диагностики
cd /d "%~dp0"
echo.
echo 15  Разбор заявки TLS / сертификаты
echo 16  Обновить кэш CRL
echo  0  Полный сбор
echo  1  DNS
echo  2  Лицензия КриптоПро
echo  3  Контейнеры и сертификаты
echo  4  Службы КриптоПро
echo  5  Континент TLS: шлюз и адреса
echo  6  Не нажимать восстановление TLS
echo  7  Оборвать сессию TLS
echo  8  Рутокен
echo  9  IP для заявки в ЦИТ
echo 10  ViPNet
echo 11  Secret Net Studio
echo 12  Dallas Lock
echo 13  Адреса баз 1С
echo 14  Таймаут шлюза 1С
echo.
set /p N=Номер: 
if "%N%"=="0" call "%~dp0\00-sborshik-polnoy-diagnostiki.bat"
if "%N%"=="1" call "%~dp0\01-dns-ne-rabotaet.bat"
if "%N%"=="2" call "%~dp0\02-cryptopro-licenziya.bat"
if "%N%"=="3" call "%~dp0\03-cryptopro-konteynery-i-sertifikaty.bat"
if "%N%"=="4" call "%~dp0\04-cryptopro-sluzhby.bat"
if "%N%"=="5" call "%~dp0\05-continent-tls-shlyuz-i-adresa.bat"
if "%N%"=="6" call "%~dp0\06-continent-tls-ne-vosstanavlivat.bat"
if "%N%"=="7" call "%~dp0\07-continent-tls-obryv-sessii.bat"
if "%N%"=="8" call "%~dp0\08-rutoken-i-nositeli.bat"
if "%N%"=="9" call "%~dp0\09-moy-ip-dlya-zayavki.bat"
if "%N%"=="10" call "%~dp0\10-vipnet-status.bat"
if "%N%"=="11" call "%~dp0\11-secretnet-studio-status.bat"
if "%N%"=="12" call "%~dp0\12-dallas-lock-status.bat"
if "%N%"=="13" call "%~dp0\13-1c-adresa-baz.bat"
if "%N%"=="14" call "%~dp0\14-1c-gateway-timeout.bat"
if "%N%"=="15" call "%~dp0\15-razbor-zayavki.bat"
if "%N%"=="16" call "%~dp0\16-obnovit-crl.bat"
echo.
