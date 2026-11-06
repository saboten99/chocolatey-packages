# CI checks run after install / uninstall. Not included in the .nupkg.
param([ValidateSet('installed', 'uninstalled')] [string] $Phase)
$ErrorActionPreference = 'Stop'

$exe      = Join-Path $env:ChocolateyInstall 'lib\gopher64\tools\gopher64.exe'
$shim     = Join-Path $env:ChocolateyInstall 'bin\gopher64.exe'
$shortcut = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'Gopher64.lnk'

if ($Phase -eq 'installed') {
  foreach ($p in $exe, "$exe.gui", $shim, $shortcut) {
    if (-not (Test-Path $p)) { throw "Missing after install: $p" }
  }
  $sig = Get-AuthenticodeSignature $exe
  Write-Host "Signature: $($sig.Status) - $($sig.SignerCertificate.Subject)"
  Write-Host "gopher64 install checks passed"
} else {
  foreach ($p in $exe, $shim, $shortcut) {
    if (Test-Path $p) { throw "Still present after uninstall: $p" }
  }
  Write-Host "gopher64 uninstall checks passed"
}
