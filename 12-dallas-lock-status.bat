@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Dallas Lock
call "%~dp0_lib.bat" begin "Dallas Lock статус"
call "%~dp0_lib.bat" log "Проверка Dallas Lock: установлен ли продукт и в каком состоянии службы. Скрипт защиту не снимает."
call "%~dp0_lib.bat" run "Установка и службы" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\products.ps1"
call "%~dp0_lib.bat" log "Если Dallas Lock в списке программ нет — на этом ПК он не установлен. Остановленная служба при установленной защите — заявка администратору Dallas Lock."
call "%~dp0_lib.bat" done
endlocal
