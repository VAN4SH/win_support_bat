@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Обновить кэш CRL
call "%~dp0_lib.bat" begin "Обновление CRL"
call "%~dp0_lib.bat" log "Если цепочка ругается на отзыв или списки устарели: сбрасывается кэш CRL Windows. Сертификаты не удаляются. Следующая проверка скачает списки заново."
call "%~dp0_lib.bat" run "Кэш CRL сейчас" "certutil -urlcache CRL"
echo.
set /p GO=Сбросить кэш CRL? Y/N: 
if /i "%GO%"=="Y" (
  certutil -urlcache * delete >> "%LOGDIR%\report.txt" 2>&1
  call "%~dp0_lib.bat" log "Кэш сброшен. В заявку, если после этого сайты открылись: Обновлены списки CRL. Списки отзыва сертификатов (CRL) успешно обновлены."
) else (
  call "%~dp0_lib.bat" log "Сброс отменён."
)
call "%~dp0_lib.bat" done
endlocal
