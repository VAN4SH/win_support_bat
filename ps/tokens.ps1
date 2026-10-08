Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
  Where-Object { $_.FriendlyName -match 'Rutoken|Рутокен|Aktiv|Smart Card|eToken|JaCarta|смарт' } |
  Format-Table Status, Class, FriendlyName -AutoSize
Write-Output '---- drivers ----'
$drivers = @(Get-CimInstance Win32_PnPSignedDriver -ErrorAction SilentlyContinue |
  Where-Object { $_.DeviceName -match 'Rutoken|Рутокен|Aktiv|eToken|JaCarta' })
$drivers | Select-Object DeviceName, DriverVersion, DriverDate | Format-List
$dates = @()
foreach ($d in $drivers) {
  try {
    if ($d.DriverDate) { $dates += [datetime]$d.DriverDate }
  } catch {}
}
$newest = $null
$oldest = $null
if ($dates.Count -gt 0) {
  $newest = ($dates | Measure-Object -Maximum).Maximum
  $oldest = ($dates | Measure-Object -Minimum).Minimum
}
if (-not $newest) {
  Write-Output 'Дату драйвера Рутокен прочитать не удалось. Если клиент Континент TLS не ставится (0x80070643 / неправильный алгоритм) — ставят заново с https://www.rutoken.ru/support/download/windows/'
} elseif ($oldest -lt (Get-Date).AddMonths(-18)) {
  Write-Output ("Драйвер старше 18 месяцев (самый старый {0:yyyy-MM-dd}). Для установки Континент TLS меняют на актуальный, даже если статус устройства OK." -f $oldest)
} elseif ($newest -ge (Get-Date).AddMonths(-12)) {
  Write-Output ("Дата драйвера за последний год (новейший {0:yyyy-MM-dd}). Если установщик TLS всё равно падает — один раз ставят драйвер заново; повторный отказ — заявка в «Лидер софт»." -f $newest)
} else {
  Write-Output ("Драйвер не старше 18 месяцев, но и не за последний год ({0:yyyy-MM-dd}). При сбое установки TLS лучше обновить с сайта Aktiv." -f $newest)
}
Write-Output 'Ссылки: https://www.rutoken.ru/support/download/windows/  и  https://www.rutoken.ru/support/download/stable/'
