# YouTube Music -> Discord RPC: Windows oturum acilisinda otomatik baslatmayi kurar.
# Yonetici (admin) GEREKMEZ. Calistir: sag tik -> "PowerShell ile calistir"
#   veya:  powershell -ExecutionPolicy Bypass -File install-autostart.ps1
$ErrorActionPreference = 'Stop'

$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vbs    = Join-Path $appDir 'run-hidden.vbs'

if (-not (Test-Path $vbs)) { throw "run-hidden.vbs bulunamadi: $vbs" }

# Baslangic klasorune gizli baslatici kisayolu olustur
$startup = [Environment]::GetFolderPath('Startup')
$lnk     = Join-Path $startup 'YTMusic Discord RPC.lnk'

$ws = New-Object -ComObject WScript.Shell
$sc = $ws.CreateShortcut($lnk)
$sc.TargetPath       = 'wscript.exe'          # wscript penceresizdir
$sc.Arguments        = '"' + $vbs + '"'
$sc.WorkingDirectory = $appDir
$sc.Description       = 'YouTube Music -> Discord Rich Presence'
$sc.Save()
Write-Host "[OK] Otomatik baslatma kuruldu:" $lnk

# Zaten calisan eski ornekleri temizle (cift instance / port cakismasi olmasin)
Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue |
  Where-Object { $_.CommandLine -match 'index\.js' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

# Simdi de gizli olarak baslat (yeniden baslatmaya gerek kalmasin)
Start-Process wscript.exe -ArgumentList ('"' + $vbs + '"') -WorkingDirectory $appDir
Write-Host "[OK] Uygulama gizli olarak baslatildi. Discord masaustu acik oldugundan emin ol."
Write-Host "Durdurmak icin: uninstall-autostart.ps1"
