@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Рутокен и носители
call "%~dp0_lib.bat" begin "Рутокен и носители"
call "%~dp0_lib.bat" log "БЗ: 0x80070643 при установке TLS и «неправильный алгоритм» — сначала драйвер Рутокена, не сертификаты и не *.cap.ru."
call "%~dp0_lib.bat" log "Старый драйвер ломает установщик, даже когда токен в диспетчере без ошибки. Старше 18 месяцев — старый; свежий — в пределах 12 месяцев."
call "%~dp0_lib.bat" log "Скрипт драйвер не скачивает. Ставят/переустанавливают с https://www.rutoken.ru/support/download/windows/ (stable: https://www.rutoken.ru/support/download/stable/) и заново запускают установщик клиента."
call "%~dp0_lib.bat" log "В заявку после успешной установки: Обновлён драйвер Рутокена. Результат: Восстановлен TLS Клиент."
call "%~dp0_lib.bat" run "Служба смарт-карт" "sc query SCardSvr"
call "%~dp0_lib.bat" run "Устройства и драйверы" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\tokens.ps1"
call "%~dp0_lib.bat" findcsp
if defined CSP call "%~dp0_lib.bat" run "Контейнеры на носителях" "%CSP%\csptest.exe" -keyset -enum_containers -fqcn -verifycontext
call "%~dp0_lib.bat" done
endlocal
