# Eklentiyi Firefox/Floorp'un kabul ettigi bir .xpi olarak paketler.
# ONEMLI: PowerShell'in "Compress-Archive" komutuyla yapilan zip'i Firefox bazen
# "bozuk" sayip reddeder. Bu script .NET ZipFile API kullanir; manifest.json
# arsivin KOKUNDE olur ve dosya gecerli sekilde olusur.
#
# Calistir:  powershell -ExecutionPolicy Bypass -File build-xpi.ps1
$ErrorActionPreference = 'Stop'

$src = Split-Path -Parent $MyInvocation.MyCommand.Path        # extension/ klasoru
$out = Join-Path (Split-Path -Parent $src) 'ytmusic-discord-rpc.xpi'

# Sadece eklenti dosyalarini gecici bir klasore topla (script/eski cikti haric)
$include = @('manifest.json', 'background.js', 'content.js')
$stage = Join-Path $env:TEMP ('ytm-xpi-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage -Force | Out-Null
try {
  foreach ($name in $include) {
    $p = Join-Path $src $name
    if (-not (Test-Path $p)) { throw "Eksik dosya: $name" }
    Copy-Item $p (Join-Path $stage $name) -Force
    Write-Host "  + $name"
  }

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  if (Test-Path $out) { Remove-Item $out -Force }
  # includeBaseDirectory = $false -> dosyalar arsivin kokunde olur
  [System.IO.Compression.ZipFile]::CreateFromDirectory(
    $stage, $out, [System.IO.Compression.CompressionLevel]::Optimal, $false)
}
finally {
  Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "[OK] Olusturuldu: $out"
Write-Host "Kur: about:addons -> disli -> 'Dosyadan Eklenti Yukle' -> bu .xpi"
