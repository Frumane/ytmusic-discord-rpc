# Eklentiyi Mozilla AMO'da 'unlisted' olarak imzalatir ve imzali .xpi'yi indirir.
# Imzali XPI her Firefox/Floorp'ta imza ayari kapatmadan kurulabilir; GitHub'da dagitilabilir.
#
# 1) https://addons.mozilla.org/developers/addon/api/key/ adresinden API anahtari uret.
# 2) Anahtarlari ortam degiskenine koy (bu pencerede):
#      $env:WEB_EXT_API_KEY    = "user:1234567:890"
#      $env:WEB_EXT_API_SECRET = "abcdef...."
# 3) Bu scripti calistir:
#      powershell -ExecutionPolicy Bypass -File sign.ps1
#
# Sonuc: ../web-ext-artifacts/ icine imzali .xpi duser.
$ErrorActionPreference = 'Stop'

$ext       = Split-Path -Parent $MyInvocation.MyCommand.Path
$artifacts = Join-Path (Split-Path -Parent $ext) 'web-ext-artifacts'

if (-not $env:WEB_EXT_API_KEY -or -not $env:WEB_EXT_API_SECRET) {
  Write-Host "[HATA] Once AMO anahtarlarini ayarla:" -ForegroundColor Red
  Write-Host '  $env:WEB_EXT_API_KEY    = "user:XXXXXXX:NN"'
  Write-Host '  $env:WEB_EXT_API_SECRET = "...."'
  exit 1
}

# web-ext, WEB_EXT_API_KEY / WEB_EXT_API_SECRET degiskenlerini otomatik okur.
# Repo scriptleri pakete girmesin diye --ignore-files ile disla.
npx --yes web-ext sign `
  --source-dir "$ext" `
  --channel unlisted `
  --artifacts-dir "$artifacts" `
  --ignore-files build-xpi.ps1 sign.ps1

Write-Host "[OK] Imzali .xpi: $artifacts" -ForegroundColor Green
