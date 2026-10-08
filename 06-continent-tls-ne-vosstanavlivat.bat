@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Не нажимать восстановление TLS
call "%~dp0_lib.bat" begin "Не восстанавливать TLS"
call "%~dp0_lib.bat" log "БЗ: окно «Восстановление TLS», кракозябры, регистрационный номер, версия 1440."
call "%~dp0_lib.bat" log "ЭТО ОКНО НЕ НАЖИМАТЬ. Особенно если рядом идёт перезагрузка Windows: может застрять CheckReboot=1, после чего повторные установки и чистка уже не помогают."
call "%~dp0_lib.bat" log "Скрипт клиент TLS не запускает и «восстановление» не жмёт."
call "%~dp0_lib.bat" run "Установленные клиенты" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\products.ps1"
call "%~dp0_lib.bat" log "В заявку: ситуация «Не работает Континент TLS», действие «Пользователь направлен в «Лидер софт»». Если уже нажали восстановление и клиент сломан — у «Лидер софт» / «Кода Безопасности» спрашивают переход на Континент ZTN Client (по нему есть сертификат поддержки)."
call "%~dp0_lib.bat" done
endlocal
