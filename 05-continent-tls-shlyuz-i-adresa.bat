@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Континент TLS: шлюз и адреса
call "%~dp0_lib.bat" begin "Континент TLS шлюз и адреса"
call "%~dp0_lib.bat" log "БЗ: HTTP/SSL к https://cb.cap.ru, 0x8009030d — сначала смотрят адрес базы и шлюз, не сертификаты."
call "%~dp0_lib.bat" log "Основной шлюз TLS1: cb.cap.ru / cbmbou-dgu.cap.ru. Резервный TLS2: cb2.cap.ru / cbmbou-dgu2.cap.ru. В тонком клиенте 1С для ЕИС часто нужен https://cb1.cap.ru."
call "%~dp0_lib.bat" run "Продукты" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\products.ps1"
call "%~dp0_lib.bat" run "cb.cap.ru (TLS1)" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\check-host.ps1 -HostName cb.cap.ru"
call "%~dp0_lib.bat" run "cb1.cap.ru" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\check-host.ps1 -HostName cb1.cap.ru"
call "%~dp0_lib.bat" run "cb2.cap.ru (TLS2 резерв)" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\check-host.ps1 -HostName cb2.cap.ru"
call "%~dp0_lib.bat" log "Если падает только cb.cap.ru, а cb2 открывается — в Континент TLS и в тонком клиенте переключают на резервный шлюз TLS2 (cb2 / cbmbou-dgu2). Если открывается только cb1 — в базах 1С ставят https://cb1.cap.ru (скрипт 13, файл не меняет)."
call "%~dp0_lib.bat" log "Если все *.cap.ru молчат, а клиент TLS и сертификаты на месте — ситуация «Нет доступа к *cap.ru», человека направляют в АУ «ЦИТ». Версию 1482 меняют на 1483, окно «Восстановление TLS» не нажимают."
call "%~dp0_lib.bat" done
endlocal
