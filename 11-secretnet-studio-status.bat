@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Secret Net Studio
call "%~dp0_lib.bat" begin "Secret Net Studio статус"
call "%~dp0_lib.bat" log "Проверка Secret Net Studio: продукт, службы, агент. Скрипт защиту не выключает и политики не меняет."
call "%~dp0_lib.bat" run "Установка и службы" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\products.ps1"
call "%~dp0_lib.bat" log "В отчёте найдите строки Secret Net / SNS. Если продукт есть, а служба остановлена — это повод для заявки администратору SNS, а не для удаления агента."
call "%~dp0_lib.bat" done
endlocal
