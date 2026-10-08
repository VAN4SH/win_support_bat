# Разбор заявки: Континент TLS, доступ к *.cap.ru, три вида сертификатов.
# Печатает ситуацию, действие и формулировку для закрытия — из словаря техподдержки.
# Опирается на типовые ошибки БЗ: 0x80070643, неправильный алгоритм, 0x8009030d,
# Gateway timeout, белый список IP, 1482→1483, «Восстановление TLS» / 1440.
$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Say($text) { [Console]::Out.WriteLine([string]$text) }

function Find-TlsClient {
  $hits = @()
  $keys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )
  $apps = Get-ItemProperty $keys | Where-Object { $_.DisplayName -match 'Continent TLS|Континент TLS' }
  foreach ($a in $apps) {
    $hits += [pscustomobject]@{
      Name = $a.DisplayName
      Version = [string]$a.DisplayVersion
      Location = [string]$a.InstallLocation
    }
  }
  $roots = @($apps.InstallLocation | Where-Object { $_ }) + @(
    "$env:ProgramFiles\Security Code",
    "$env:ProgramFiles\Код Безопасности",
    "${env:ProgramFiles(x86)}\Security Code",
    "${env:ProgramFiles(x86)}\Код Безопасности"
  )
  $exes = foreach ($r in ($roots | Select-Object -Unique)) {
    if ($r -and (Test-Path $r)) {
      Get-ChildItem -Path $r -Recurse -Include 'TLSClient.exe','ContinentTLS.exe','ctls.exe' -ErrorAction SilentlyContinue
    }
  }
  $builds = @()
  foreach ($x in $exes) {
    $info = [Diagnostics.FileVersionInfo]::GetVersionInfo($x.FullName)
    $blob = "$($info.FileVersion) $($info.ProductVersion) $($info.FileDescription)"
    $build = $null
    if ($blob -match '(?<!\d)(1[0-9]{3})(?!\d)') { $build = [int]$Matches[1] }
    $builds += [pscustomobject]@{ Path = $x.FullName; Blob = $blob; Build = $build }
  }
  [pscustomobject]@{ Apps = $hits; Files = $builds; Places = @($roots | Select-Object -Unique) }
}

function Test-Cap {
  $hosts = @(
    @{ Name = 'cb.cap.ru'; Role = 'TLS1 основной' },
    @{ Name = 'cb1.cap.ru'; Role = 'тонкий клиент ЕИС' },
    @{ Name = 'cb2.cap.ru'; Role = 'TLS2 резерв' }
  )
  $okAny = $false
  $okMain = $false
  $okReserve = $false
  $okCb1 = $false
  foreach ($h in $hosts) {
    Say ("---- {0} ({1}) ----" -f $h.Name, $h.Role)
    try {
      $dns = Resolve-DnsName $h.Name | Select-Object -First 4
      foreach ($d in $dns) { Say ("  dns {0} {1}" -f $d.Name, $d.IPAddress) }
    } catch { Say $_.Exception.Message }
    $t = Test-NetConnection $h.Name -Port 443 -WarningAction SilentlyContinue
    Say ("ping={0} tcp443={1}" -f $t.PingSucceeded, $t.TcpTestSucceeded)
    if ($t.TcpTestSucceeded) {
      $okAny = $true
      if ($h.Name -eq 'cb.cap.ru') { $okMain = $true }
      if ($h.Name -eq 'cb2.cap.ru') { $okReserve = $true }
      if ($h.Name -eq 'cb1.cap.ru') { $okCb1 = $true }
    }
  }
  [pscustomobject]@{ Ok = $okAny; Main = $okMain; Reserve = $okReserve; Cb1 = $okCb1 }
}

function Get-StoreCerts($path) {
  @(Get-ChildItem $path -ErrorAction SilentlyContinue)
}

function Get-RutokenState {
  Say '==== Рутокен ===='
  $tokens = @(Get-PnpDevice -PresentOnly | Where-Object { $_.FriendlyName -match 'Rutoken|Рутокен' })
  $bad = @($tokens | Where-Object { $_.Status -ne 'OK' }).Count -gt 0
  if ($tokens.Count -eq 0) { Say 'Рутокен сейчас не подключён. Для установки клиента важен драйвер на компьютере, не только вставленный токен.' }
  else { $tokens | ForEach-Object { Say ("{0}  {1}" -f $_.Status, $_.FriendlyName) } }
  $drivers = @(Get-CimInstance Win32_PnPSignedDriver | Where-Object { $_.DeviceName -match 'Rutoken|Рутокен' })
  $dates = @()
  foreach ($d in $drivers) {
    $dt = $null
    try { if ($d.DriverDate) { $dt = [datetime]$d.DriverDate } } catch {}
    $shown = if ($dt) { $dt.ToString('yyyy-MM-dd') } else { 'дата не прочитана' }
    Say ("драйвер устройства: {0}  версия={1}  дата={2}" -f $d.DeviceName, $d.DriverVersion, $shown)
    if ($dt) { $dates += $dt }
  }
  $keys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )
  $pkgs = @(Get-ItemProperty $keys | Where-Object { $_.DisplayName -match 'Rutoken|Рутокен' })
  foreach ($p in $pkgs) { Say ("пакет: {0}  версия={1}" -f $p.DisplayName, $p.DisplayVersion) }
  $newest = $null
  if ($dates.Count -gt 0) { $newest = ($dates | Measure-Object -Maximum).Maximum }
  $fresh = [bool]($newest -and $newest -ge (Get-Date).AddMonths(-12))
  $old = $bad -or ($drivers.Count -eq 0 -and $pkgs.Count -eq 0) -or ($newest -and $newest -lt (Get-Date).AddMonths(-18))
  if ($drivers.Count -eq 0 -and $pkgs.Count -eq 0) { Say 'Пакет драйвера Рутокен не найден. Ссылки: https://www.rutoken.ru/support/download/windows/' }
  elseif ($newest -and $newest -lt (Get-Date).AddMonths(-18)) { Say 'Драйвер старше 18 месяцев. Устройство при этом может быть без ошибки, а установщик Континент TLS всё равно не проходит (0x80070643 / неправильный алгоритм).' }
  elseif ($fresh) { Say 'Дата драйвера за последний год.' }
  else { Say 'Дату драйвера прочитать не удалось или она между 12 и 18 месяцами — при сбое установки TLS лучше обновить.' }
  [pscustomobject]@{ Bad = $bad; Old = [bool]$old; Fresh = $fresh }
}

$ru = 'ГУЦ|Минцифр|Казначей|КриптоПро|CryptoPro|Удостоверяющ|ФНС|ФК |Головной'
Say '==== Континент TLS ===='
$tls = Find-TlsClient
$tlsInstalled = @($tls.Apps).Count -gt 0 -or @($tls.Files).Count -gt 0
if (-not $tlsInstalled) { Say 'Клиент Континент TLS в системе не найден.' }
$tls.Apps | ForEach-Object { Say ("установлен: {0}  версия={1}  путь={2}" -f $_.Name, $_.Version, $_.Location) }
$builds = @($tls.Files | Where-Object { $_.Build })
$tls.Files | ForEach-Object { Say ("файл: {0}  версия={1}" -f $_.Path, $_.Blob) }
$running = @(Get-Process | Where-Object { $_.ProcessName -match 'TLSClient|ContinentTLS|^ctls$' })
Say ("процесс клиента запущен: {0}" -f ($(if ($running) {'да'} else {'нет'})))
$cerNear = @()
foreach ($r in @($tls.Places)) {
  if ($r -and (Test-Path $r)) {
    $cerNear += @(Get-ChildItem $r -Recurse -Include *.cer,*.crt -ErrorAction SilentlyContinue | Select-Object -First 30)
  }
}
Say ("файлы .cer/.crt рядом с клиентом: {0}" -f @($cerNear).Count)
$seen1440 = @($tls.Files | Where-Object { $_.Blob -match '1440' -or $_.Build -eq 1440 }).Count -gt 0
$old1482 = @($builds | Where-Object { $_.Build -eq 1482 }).Count -gt 0
$has1483 = @($builds | Where-Object { $_.Build -ge 1483 }).Count -gt 0
$rutoken = Get-RutokenState

if (-not $tlsInstalled) {
  Say ''
  Say 'Клиент Континент TLS не установлен. Пока установщик не прошёл, сертификаты и доступ к *.cap.ru не разбирают.'
  Say 'Сначала ставят актуальный драйвер Рутокен с https://www.rutoken.ru/support/download/windows/ и заново запускают установщик клиента.'
  Say 'Окно «Восстановление TLS» в этом случае не при чём.'
  Say ''
  Say '========== ДЛЯ ЗАЯВКИ =========='
  Say 'СИТУАЦИЯ (кратко -> текст в заявку):'
  Say '- Не работает Континент TLS.|У пользователя не работает Континент TLS Клиент.'
  Say 'ДЕЙСТВИЕ, которое закрывает причину (в заявку писать уже после того, как сделали):'
  if ($rutoken.Fresh) {
    Say '- драйвер по дате свежий. Если после повторной установки актуального драйвера клиент всё равно не встаёт: Пользователь направлен в «Лидер софт».|Пользователь перенаправлен в «Лидер софт» для дальнейшего решения.'
  } else {
    Say '- Обновлён драйвер Рутокена.|Драйвер Рутокен обновлён до актуальной версии.'
  }
  Say 'РЕЗУЛЬТАТ, если после драйвера клиент установился и подключился:'
  Say '- Восстановлен TLS Клиент. | Работоспособность Континент TLS Клиента восстановлена.'
  Say '- Работоспособность проверена. | Проведена проверка работоспособности, всё функционирует корректно.'
  exit 0
}

Say '==== Доступ *.cap.ru ===='
$cap = Test-Cap
$capOk = [bool]$cap.Ok

if (-not $cap.Main -and $cap.Reserve) {
  Say 'Подсказка БЗ (0x8009030d / SSL к cb.cap.ru): основной TLS1 молчит, резервный TLS2 (cb2) отвечает — в Континент TLS и тонком клиенте переключают на резервный шлюз (cb2.cap.ru / cbmbou-dgu2.cap.ru).'
}
if (-not $cap.Main -and $cap.Cb1 -and -not $cap.Reserve) {
  Say 'Подсказка БЗ: cb.cap.ru недоступен по HTTPS, а cb1.cap.ru отвечает — в базах 1С ставят https://cb1.cap.ru (скрипт 13).'
}

Say '==== Сертификаты ===='
$personal = @(Get-StoreCerts 'Cert:\CurrentUser\My' | Where-Object { $_.HasPrivateKey })
$personalAlive = @($personal | Where-Object { $_.NotAfter -gt (Get-Date) })
$personalNoKey = @(Get-StoreCerts 'Cert:\CurrentUser\My' | Where-Object { -not $_.HasPrivateKey })
Say ("личный с закрытым ключом: {0}, из них не просрочен: {1}" -f $personal.Count, $personalAlive.Count)
if ($personalNoKey.Count -gt 0) {
  Say ("личный без закрытого ключа (контейнер не найден / «ключ не существует»): {0}" -f $personalNoKey.Count)
}
$personalAlive | Select-Object -First 8 | ForEach-Object {
  Say ("  {0}  до {1:yyyy-MM-dd}  {2}" -f $_.Subject, $_.NotAfter, $_.Issuer)
}

$serverPool = @(
  (Get-StoreCerts 'Cert:\CurrentUser\CA') +
  (Get-StoreCerts 'Cert:\LocalMachine\CA') +
  (Get-StoreCerts 'Cert:\CurrentUser\AddressBook')
) | Where-Object { $_ -and ($_.Subject -match $ru -or $_.Issuer -match $ru -or $_.Subject -match 'cap\.ru|Континент') }
Say ("серверный/промежуточный (УЦ, Континент, *.cap.ru): {0}" -f @($serverPool).Count)
@($serverPool) | Select-Object -First 8 | ForEach-Object { Say ("  {0}" -f $_.Subject) }

$roots = @(
  (Get-StoreCerts 'Cert:\LocalMachine\Root') +
  (Get-StoreCerts 'Cert:\CurrentUser\Root')
) | Where-Object { $_ -and ($_.Subject -match $ru) }
Say ("корневой российский УЦ: {0}" -f @($roots).Count)
@($roots) | Select-Object -First 6 | ForEach-Object { Say ("  {0}" -f $_.Subject) }

Say '==== CRL ===='
$crlText = & certutil -urlcache CRL 2>&1 | Out-String
$crlLines = @($crlText -split "`n" | Where-Object { $_.Trim() -ne '' } | Select-Object -First 12)
if ($crlLines.Count -eq 0) { Say 'кэш CRL пуст' } else { $crlLines | ForEach-Object { Say $_ } }
$crlEmpty = $crlText -notmatch 'http'

Say '==== Цепочка личного сертификата ===='
$chainBroken = $false
if ($personalAlive.Count -gt 0) {
  $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
  $chain.ChainPolicy.RevocationMode = 'Online'
  $chain.ChainPolicy.UrlRetrievalTimeout = New-TimeSpan -Seconds 8
  $okChain = $chain.Build($personalAlive[0])
  Say ("цепочка для первого живого личного: {0}" -f $(if ($okChain) {'собрана'} else {'НЕ собрана'}))
  if (-not $okChain) {
    $onlyCrl = $true
    foreach ($st in @($chain.ChainStatus)) {
      Say ("  {0}" -f $st.StatusInformation)
      if ($st.Status -ne 'RevocationStatusUnknown' -and $st.Status -ne 'OfflineRevocation') { $onlyCrl = $false }
    }
    if ($onlyCrl) { $crlEmpty = $true } else { $chainBroken = $true }
  }
} else {
  Say 'проверять нечего: живого личного сертификата нет'
}

Say '==== Лицензия КриптоПро ===='
$csp = @(
  "$env:ProgramFiles\Crypto Pro\CSP\cpconfig.exe",
  "${env:ProgramFiles(x86)}\Crypto Pro\CSP\cpconfig.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
$licenseBad = $false
if ($csp) {
  $lic = & $csp -license -view 2>&1 | Out-String
  Say $lic
  if ($lic -match 'expired|истек|истёк') { $licenseBad = $true }
} else { Say 'cpconfig не найден' }

$keyMissing = ($personalAlive.Count -eq 0 -and $personalNoKey.Count -gt 0)
$needReserveSwitch = (-not $cap.Main -and $cap.Reserve)
$needCb1Address = (-not $cap.Main -and $cap.Cb1)

Say ''
Say '========== ДЛЯ ЗАЯВКИ =========='
$situations = @()
if ($seen1440) { $situations += 'Не работает Континент TLS.|У пользователя не работает Континент TLS Клиент.' }
elseif (-not $running) { Say 'Клиент установлен, процесс не запущен. Сначала открыть Континент TLS и подключиться. Это ещё не смена сертификатов.' }
if (-not $capOk) { $situations += 'Нет доступа к *cap.ru.|У пользователя отсутствует доступ к ресурсу *cap.ru.' }
elseif ($needReserveSwitch -or $needCb1Address) {
  $situations += 'Нет доступа к *cap.ru.|У пользователя отсутствует доступ к ресурсу *cap.ru.'
  Say 'Локально до словаря: переключение шлюза/адреса базы часто закрывает 0x8009030d без эскалации.'
}
if ($personalAlive.Count -eq 0) { $situations += 'Отсутствует личный сертификат пользователя.|У пользователя отсутствует личный сертификат.' }
if (@($serverPool).Count -eq 0 -and @($cerNear).Count -eq 0) { $situations += 'Отсутствует серверный сертификат пользователя.|У пользователя отсутствует серверный сертификат.' }
if (@($roots).Count -eq 0) { $situations += 'Отсутствует корневой сертификат пользователя.|У пользователя отсутствует корневой сертификат.' }
if ($situations.Count -eq 0) { $situations += 'Работоспособность проверена.|Проведена проверка работоспособности, всё функционирует корректно.' }

$actions = @()
if ($old1482 -and -not $has1483) { $actions += 'TLS обновлён с 1482 до 1483.|Версия Континент TLS Клиента обновлена с 1482 до 1483.' }
if ($crlEmpty) { $actions += 'Обновлены списки CRL.|Списки отзыва сертификатов (CRL) успешно обновлены.' }
if ($chainBroken) { $actions += 'Исправлена цепочка сертификатов.|Цепочка сертификатов восстановлена и корректна.' }
if ($personalAlive.Count -eq 0 -and -not $keyMissing) { $actions += 'Установлен личный сертификат.|Личный сертификат пользователя успешно установлен.' }
if ($keyMissing) {
  Say 'Подсказка БЗ («ключ не существует» / нет контейнера): перевыпуск через АУ «ЦИТ», закрытый ключ не экспортируют.'
  $actions += 'Пользователь направлен в АУ «ЦИТ».|Пользователь перенаправлен в АУ «ЦИТ» для дальнейшего решения.'
}
if (@($serverPool).Count -eq 0 -and @($cerNear).Count -eq 0) { $actions += 'Установлен серверный сертификат.|Серверный сертификат пользователя установлен.' }
if (@($roots).Count -eq 0) { $actions += 'Установлен корневой сертификат.|Корневой сертификат пользователя установлен.' }
if ($rutoken.Old -or $rutoken.Bad) { $actions += 'Обновлён драйвер Рутокена.|Драйвер Рутокен обновлён до актуальной версии.' }
if ($licenseBad) { $actions += 'Пользователь направлен в коммерческий отдел.|Пользователь перенаправлен в коммерческий отдел для дальнейшего решения.' }
elseif ($seen1440) {
  $actions += 'Пользователь направлен в «Лидер софт».|Пользователь перенаправлен в «Лидер софт» для дальнейшего решения.'
  Say 'Подсказка БЗ (1440 / «Восстановление TLS»): не нажимать. У «Лидер софт» можно спросить переход на Континент ZTN Client.'
}
elseif ($tlsInstalled -and $personalAlive.Count -gt 0 -and -not $capOk -and -not $needReserveSwitch -and -not $needCb1Address) {
  $actions += 'Пользователь направлен в АУ «ЦИТ».|Пользователь перенаправлен в АУ «ЦИТ» для дальнейшего решения.'
  Say 'Подсказка БЗ: при живых сертификатах и TLS внешний IP сверить (скрипт 09 / inet.ya.ru) и передать в ЦИТ для белого списка.'
}

Say 'СИТУАЦИЯ (кратко -> текст в заявку):'
$situations | ForEach-Object { Say ("- {0}" -f $_) }
Say 'ДЕЙСТВИЕ, которое закрывает причину (в заявку писать уже после того, как сделали):'
if ($actions.Count -eq 0) {
  if ($needReserveSwitch) { Say '- локально: переключить Континент TLS / 1С на резервный шлюз TLS2 (cb2.cap.ru). В словарь действий отдельной строки нет — после успеха пишут результат «Доступ к ресурсу восстановлен».' }
  elseif ($needCb1Address) { Say '- локально: в базах 1С заменить https://cb.cap.ru на https://cb1.cap.ru (скрипт 13). После успеха — «Доступ к ресурсу восстановлен».' }
  else { Say '- ничего из словаря действий не требуется, достаточно проверки' }
} else { $actions | ForEach-Object { Say ("- {0}" -f $_) } }
Say 'РЕЗУЛЬТАТ, если после действия всё открылось:'
if (-not $capOk -or -not $tlsInstalled -or $needReserveSwitch -or $needCb1Address) {
  Say '- Восстановлен TLS Клиент. | Работоспособность Континент TLS Клиента восстановлена.'
  Say '- Доступ к ресурсу восстановлен. | Доступ пользователя к ресурсу *cap.ru восстановлен.'
}
Say '- Работоспособность проверена. | Проведена проверка работоспособности, всё функционирует корректно.'
Say 'Скрипт сертификаты сам не ставит и клиент TLS не обновляет: дистрибутив и файлы .cer берутся из вашего комплекта, затем эту проверку запускают ещё раз.'
Say 'Gateway timeout на /e1cib/login при живом 443 — сторона сервера 1С, не этот разбор (скрипт 14).'
