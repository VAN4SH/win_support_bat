param([Parameter(Mandatory=$true)][string]$HostName)
Write-Output "==== $HostName ===="
try { Resolve-DnsName $HostName -ErrorAction Stop | Format-Table -AutoSize } catch { Write-Output $_.Exception.Message }
try { Test-NetConnection $HostName -Port 443 -WarningAction SilentlyContinue | Format-List ComputerName,RemoteAddress,PingSucceeded,TcpTestSucceeded } catch { Write-Output $_.Exception.Message }
