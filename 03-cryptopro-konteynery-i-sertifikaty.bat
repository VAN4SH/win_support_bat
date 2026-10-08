@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Контейнеры и сертификаты КриптоПро
call "%~dp0_lib.bat" begin "Контейнеры и сертификаты КриптоПро"
call "%~dp0_lib.bat" log "БЗ: «ключ не существует» (0x8009000D), «неправильный открытый ключ поставщика», при установке личного — «не найден контейнер»."
call "%~dp0_lib.bat" log "Скрипт только показывает носители, контейнеры и открытые данные сертификатов. Закрытые ключи не копирует и не экспортирует."
call "%~dp0_lib.bat" findcsp
if defined CSP (
  call "%~dp0_lib.bat" run "Считыватели и контейнеры" "%CSP%\csptest.exe" -keyset -enum_containers -fqcn -verifycontext
  call "%~dp0_lib.bat" run "certmgr пользователя" "%CSP%\certmgr.exe" -list -store uMy
) else (
  call "%~dp0_lib.bat" log "csptest/certmgr не найдены, показан только certutil."
)
call "%~dp0_lib.bat" run "Хранилище пользователя My" "certutil -store -user My"
call "%~dp0_lib.bat" run "Корневые сертификаты пользователя" "certutil -store -user Root"
call "%~dp0_lib.bat" run "Промежуточные пользователя" "certutil -store -user CA"
call "%~dp0_lib.bat" log "Три разные причины в заявке: личный (My + контейнер), серверный (промежуточный УЦ / шлюз), корневой (Root). Если контейнера на Рутокене нет — ключ реально отсутствует: перевыпуск через АУ «ЦИТ», скриншоты к заявке. Сводку формулировок даёт 15-razbor-zayavki.bat."
call "%~dp0_lib.bat" done
endlocal
