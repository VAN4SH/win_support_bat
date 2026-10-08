$roots = @(
  "$env:APPDATA\1C\1CEStart",
  "$env:LOCALAPPDATA\1C\1CEStart"
)
Get-ChildItem -Path $roots -Filter ibases.v8i -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
  Write-Output "==== $($_.FullName) ===="
  Select-String -Path $_.FullName -Pattern 'Connect=|ID=|Name=|https?://|cb\.cap\.ru|cb1\.cap\.ru|cb2\.cap\.ru|cbmbou' -ErrorAction SilentlyContinue |
    ForEach-Object { $_.Line.Trim() }
}
