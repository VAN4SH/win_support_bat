@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Лицензия КриптоПро
call "%~dp0_lib.bat" begin "Лицензия КриптоПро"
call "%~dp0_lib.bat" log "БЗ: сертификат «не действителен» только через КриптоПро. Частая причина — истекла лицензия CSP, сам сертификат при этом может быть живым."
call "%~dp0_lib.bat" findcsp
if not defined CSP (
  call "%~dp0_lib.bat" log "КриптоПро CSP не установлен или лежит в нестандартном каталоге."
  call "%~dp0_lib.bat" done
  exit /b 1
)
call "%~dp0_lib.bat" log "Каталог: %CSP%"
call "%~dp0_lib.bat" run "Версия" "%CSP%\csptest.exe" -keyset -verifycontext -enum_containers
call "%~dp0_lib.bat" run "Лицензия" "%CSP%\cpconfig.exe" -license -view
call "%~dp0_lib.bat" log "Если дата лицензии уже прошла, сертификат в плагине будет «не действителен». В заявку: Пользователь направлен в коммерческий отдел. Сертификаты этот скрипт не удаляет."
call "%~dp0_lib.bat" done
endlocal
