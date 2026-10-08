@echo off
setlocal EnableExtensions
chcp 65001 >nul
title DNS не работает
call "%~dp0_lib.bat" begin "DNS не работает"
call "%~dp0_lib.bat" log "БЗ: на компьютере не работает DNS. Имя площадки не резолвится; IP в строке подключения при этом может открываться."
call "%~dp0_lib.bat" log "hosts с cb.cap.ru часто не помогает. Временный обход — IP в тонком клиенте (обновление 1С тогда только вручную). Это не замена починки DNS."
call "%~dp0_lib.bat" run "IP и DNS-серверы" "ipconfig /all"
call "%~dp0_lib.bat" run "nslookup cb.cap.ru" "nslookup cb.cap.ru"
call "%~dp0_lib.bat" run "nslookup cb1.cap.ru" "nslookup cb1.cap.ru"
call "%~dp0_lib.bat" run "nslookup cb2.cap.ru" "nslookup cb2.cap.ru"
call "%~dp0_lib.bat" run "Файл hosts" "type %SystemRoot%\System32\drivers\etc\hosts"
call "%~dp0_lib.bat" run "Прокси WinHTTP" "netsh winhttp show proxy"
call "%~dp0_lib.bat" run "Прокси включён" "reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings /v ProxyEnable"
call "%~dp0_lib.bat" run "Сервер прокси" "reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings /v ProxyServer"
echo.
set /p FLUSH=Сбросить кэш DNS (ipconfig /flushdns)? Y/N: 
if /i "%FLUSH%"=="Y" (
  ipconfig /flushdns
  echo Кэш DNS сброшен.>> "%LOGDIR%\report.txt"
)
call "%~dp0_lib.bat" done
endlocal
