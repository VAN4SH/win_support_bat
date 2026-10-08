@echo off
setlocal EnableExtensions
chcp 65001 >nul
title IP этого компьютера для заявки
call "%~dp0_lib.bat" begin "IP для белого списка"
call "%~dp0_lib.bat" log "БЗ: пропал доступ к ресурсам ЦИТ при живых сертификатах и Континент TLS — чаще белый список IP, не локальная починка."
call "%~dp0_lib.bat" log "Скрипт печатает локальные IPv4 и внешний IP. Белый IP организации можно сверить на inet.ya.ru. В заявку: Пользователь направлен в АУ «ЦИТ». Доступ скрипт не открывает."
call "%~dp0_lib.bat" run "Адреса" "ipconfig"
call "%~dp0_lib.bat" run "Внешний IP" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\public-ip.ps1"
call "%~dp0_lib.bat" done
endlocal
