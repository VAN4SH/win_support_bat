@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Таймаут шлюза 1С
call "%~dp0_lib.bat" begin "Таймаут шлюза 1С"
call "%~dp0_lib.bat" log "БЗ: HTTP Gateway timeout на /e1cib/login — прикладная ошибка на стороне сервера 1С. Пользователю говорят сообщить в обслуживающую организацию 1С."
call "%~dp0_lib.bat" log "Скрипт собирает время ПК, DNS и доступность площадки для вложения в заявку. Сервер 1С не чинит."
call "%~dp0_lib.bat" run "Время" "echo %DATE% %TIME% & w32tm /query /status"
call "%~dp0_lib.bat" run "cb1.cap.ru" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\check-host.ps1 -HostName cb1.cap.ru"
call "%~dp0_lib.bat" run "cb2.cap.ru" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\check-host.ps1 -HostName cb2.cap.ru"
call "%~dp0_lib.bat" run "Продукты TLS и КриптоПро" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\products.ps1"
call "%~dp0_lib.bat" log "Если TCP 443 до площадки не проходит — сначала Континент TLS и DNS (01, 05, 15). Если 443 проходит, а 1С пишет Gateway timeout — сторона сервера 1С, не ЦИТ и не драйвер Рутокена."
call "%~dp0_lib.bat" done
endlocal
