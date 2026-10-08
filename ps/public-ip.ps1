Write-Output 'Внешний IP (для белого списка ЦИТ). Белый IP организации также можно сверить на https://inet.ya.ru'
try {
  $ip = Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 8
  Write-Output $ip
} catch {
  'Внешний IP не получен (нет выхода в интернет или его режет фильтр).'
}
