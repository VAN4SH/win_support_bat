# Список установленных продуктов и связанных служб
$names = 'CryptoPro|КриптоПро|Continent|Континент TLS|ViPNet|Secret Net|Dallas|Рутокен|Rutoken|Аладдин|Aktiv'
Get-ItemProperty @(
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
) -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -match $names } |
  Select-Object DisplayName, DisplayVersion, Publisher |
  Format-List
Write-Output '---- services ----'
Get-Service | Where-Object { $_.DisplayName -match $names -or $_.Name -match 'cpcsp|SCardSvr' } |
  Format-Table Status, StartType, Name, DisplayName -AutoSize
