@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Разбор заявки TLS и сертификатов
call "%~dp0_lib.bat" begin "Разбор заявки: TLS, cap.ru, сертификаты"
call "%~dp0_lib.bat" log "Сначала этот скрипт. Он сопоставляет компьютер со словарём заявки: ситуация, действие, чем закрывать."
call "%~dp0_lib.bat" log "Личный — ключ пользователя. Серверный — шлюз или промежуточный УЦ. Корневой — корневой УЦ. Без всех трёх до *.cap.ru не доходят."
call "%~dp0_lib.bat" log "Порядок из БЗ: драйвер Рутокена раньше сертификатов и *.cap.ru; 1482→1483; резерв cb2 при 0x8009030d; «Восстановление TLS» не жать."
call "%~dp0_lib.bat" run "Разбор" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\triage.ps1"
call "%~dp0_lib.bat" done
endlocal
