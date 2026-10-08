@echo off
setlocal EnableExtensions
chcp 65001 >nul
title ViPNet
call "%~dp0_lib.bat" begin "ViPNet статус"
call "%~dp0_lib.bat" log "Проверка клиента ViPNet: установлен ли, живы ли службы и появился ли адаптер. Соединение скрипт сам не поднимает и ключи не трогает."
call "%~dp0_lib.bat" run "Установка и службы" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\products.ps1"
call "%~dp0_lib.bat" run "Адаптеры" "ipconfig /all"
call "%~dp0_lib.bat" log "Ищите адаптер с именем ViPNet. Если клиента в списке программ нет — он не установлен. Если службы остановлены — запускать их из меню ViPNet, не отключая другие средства защиты."
call "%~dp0_lib.bat" done
endlocal
