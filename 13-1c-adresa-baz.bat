@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Адреса баз 1С
call "%~dp0_lib.bat" begin "Адреса баз 1С"
call "%~dp0_lib.bat" log "БЗ: в тонком клиенте https://cb.cap.ru даёт HTTP/SSL. Для баз ЕИС ставят https://cb1.cap.ru во всех используемых базах."
call "%~dp0_lib.bat" log "При 0x8009030d на основном шлюзе смотрят также резерв: cb2.cap.ru / cbmbou-dgu2. Скрипт только показывает строки из ibases.v8i, файл не меняет."
call "%~dp0_lib.bat" run "Списки баз" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\ibases.ps1"
call "%~dp0_lib.bat" log "Если в Connect= остался cb.cap.ru без единицы — в свойствах базы в 1С меняют на https://cb1.cap.ru."
call "%~dp0_lib.bat" done
endlocal
