@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Полная диагностика рабочего места
call "%~dp0_lib.bat" begin "Полная диагностика"
call "%~dp0_lib.bat" run "ОС" "systeminfo"
call "%~dp0_lib.bat" run "Сеть" "ipconfig /all"
call "%~dp0_lib.bat" run "Маршруты" "route print"
call "%~dp0_lib.bat" run "DNS-кэш, серверы" "ipconfig /displaydns"
call "%~dp0_lib.bat" findcsp
if defined CSP (
  call "%~dp0_lib.bat" log "КриптоПро: %CSP%"
  call "%~dp0_lib.bat" run "Лицензия КриптоПро" "%CSP%\cpconfig.exe" -license -view
  call "%~dp0_lib.bat" run "Считыватели" "%CSP%\csptest.exe" -keyset -enum_containers -fqcn -verifycontext
) else (
  call "%~dp0_lib.bat" log "КриптоПро CSP не найден в Program Files."
)
call "%~dp0_lib.bat" run "Личные сертификаты пользователя" "certutil -store -user My"
call "%~dp0_lib.bat" run "Личные сертификаты компьютера" "certutil -store My"
call "%~dp0_lib.bat" run "Служба смарт-карт" "sc query SCardSvr"
call "%~dp0_lib.bat" run "Продукты и службы" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\products.ps1"
call "%~dp0_lib.bat" run "Процессы" "tasklist"
call "%~dp0_lib.bat" run "HTTPS cb.cap.ru" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\check-host.ps1 -HostName cb.cap.ru"
call "%~dp0_lib.bat" run "HTTPS cb1.cap.ru" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\check-host.ps1 -HostName cb1.cap.ru"
call "%~dp0_lib.bat" done
endlocal
