@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Обрыв сессии Континент TLS
call "%~dp0_lib.bat" begin "Обрыв сессии Континент TLS"
call "%~dp0_lib.bat" log "БЗ: после обновления сертификатов/ресурсов или удаления старых — разорвать соединение через значок TLS и выйти из трея, затем снова запустить клиент и 1С."
call "%~dp0_lib.bat" log "Если после разрыва всё ещё старое состояние — обновляют TLS 1482 → 1483. Окно «Восстановление TLS» не нажимают."
call "%~dp0_lib.bat" run "Процессы до" "tasklist"
echo.
echo Будут завершены процессы клиента Континент TLS, если они запущены.
echo Закрытый ключ и настройки не удаляются.
set /p KILL=Завершить процессы TLS? Y/N: 
if /i "%KILL%"=="Y" (
  taskkill /F /IM "TLSClient.exe" >> "%LOGDIR%\report.txt" 2>&1
  taskkill /F /IM "ctls.exe" >> "%LOGDIR%\report.txt" 2>&1
  taskkill /F /IM "ContinentTLS.exe" >> "%LOGDIR%\report.txt" 2>&1
  call "%~dp0_lib.bat" log "Процессы остановлены. Запустите клиент TLS из меню Пуск и подключитесь снова."
) else (
  call "%~dp0_lib.bat" log "Остановка отменена."
)
call "%~dp0_lib.bat" done
endlocal
