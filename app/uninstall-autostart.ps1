# YouTube Music -> Discord RPC: otomatik baslatmayi kaldirir ve calisani durdurur.
#   powershell -ExecutionPolicy Bypass -File uninstall-autostart.ps1
$ErrorActionPreference = 'SilentlyContinue'

# 1) Baslangic kisayolunu sil
$startup = [Environment]::GetFolderPath('Startup')
$lnk     = Join-Path $startup 'YTMusic Discord RPC.lnk'
if (Test-Path $lnk) { Remove-Item $lnk -Force; Write-Host "[OK] Otomatik baslatma kaldirildi." }
else { Write-Host "[i] Otomatik baslatma zaten kurulu degil." }

# 2) Once yeniden-baslatici dongusunu (wscript/run-hidden.vbs) durdur ki node geri gelmesin
Get-CimInstance Win32_Process -Filter "Name='wscript.exe'" |
  Where-Object { $_.CommandLine -match 'run-hidden\.vbs' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force }

# 3) Sonra node uygulamasini durdur
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
  Where-Object { $_.CommandLine -match 'index\.js' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force }

Write-Host "[OK] Uygulama durduruldu."
