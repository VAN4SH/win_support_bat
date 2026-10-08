@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Службы КриптоПро
call "%~dp0_lib.bat" begin "Службы КриптоПро"
call "%~dp0_lib.bat" run "Службы" "powershell -NoProfile -ExecutionPolicy Bypass -File %~dp0ps\products.ps1"
echo.
set /p RESTART=Перезапустить найденные службы КриптоПро? Y/N: 
if /i "%RESTART%"=="Y" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Service | Where-Object { $_.Name -match 'cpcsp' -or $_.DisplayName -match 'CryptoPro|КриптоПро' } | Restart-Service -Force -ErrorAction Continue"
  echo Перезапуск запрошен.>> "%LOGDIR%\report.txt"
)
call "%~dp0_lib.bat" done
endlocal
