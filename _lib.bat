@echo off
if /i "%~1"=="" exit /b 1
goto %~1

:begin
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%I"
set "LOGDIR=%USERPROFILE%\Desktop\SupportLogs\%STAMP%"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
echo.
echo Отчёт: %LOGDIR%
echo %~2> "%LOGDIR%\script.txt"
echo ==== %~2 ====
echo ==== %~2 ====>> "%LOGDIR%\report.txt"
net session >nul 2>&1
if errorlevel 1 (
  echo [!] Без прав администратора часть проверок будет неполной.
  echo [!] Без прав администратора.>> "%LOGDIR%\report.txt"
) else (
  echo [ok] Права администратора есть.
  echo [ok] Права администратора есть.>> "%LOGDIR%\report.txt"
)
exit /b 0

:log
echo %~2
echo %~2>> "%LOGDIR%\report.txt"
exit /b 0

:run
echo.
echo --- %~2 ---
echo.>> "%LOGDIR%\report.txt"
echo --- %~2 --->> "%LOGDIR%\report.txt"
if "%~3"=="" exit /b 0
> "%LOGDIR%\_step.cmd" echo @echo off
if "%~4"=="" (
  >> "%LOGDIR%\_step.cmd" echo(%~3
) else (
  >> "%LOGDIR%\_step.cmd" echo("%~3" %~4 %~5 %~6 %~7 %~8 %~9
)
call "%LOGDIR%\_step.cmd" >> "%LOGDIR%\report.txt" 2>&1
exit /b 0

:findcsp
set "CSP="
if exist "%ProgramFiles%\Crypto Pro\CSP\csptest.exe" set "CSP=%ProgramFiles%\Crypto Pro\CSP"
if not defined CSP if exist "%ProgramFiles(x86)%\Crypto Pro\CSP\csptest.exe" set "CSP=%ProgramFiles(x86)%\Crypto Pro\CSP"
exit /b 0

:done
echo.
echo Готово. Папка с отчётом:
echo %LOGDIR%
echo Готово.>> "%LOGDIR%\report.txt"
start "" "%LOGDIR%"
echo.
pause
exit /b 0
