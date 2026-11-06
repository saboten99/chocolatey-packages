$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exePath  = Join-Path $toolsDir 'gopher64.exe'

$urlX64      = 'https://github.com/gopher64/gopher64/releases/download/v1.1.42/gopher64-windows-x86_64.exe'
$checksumX64 = '38ae758816bc26a255a0fb59197148001cc59c8b764af3439566147ee57cad68'

$urlArm64      = 'https://github.com/gopher64/gopher64/releases/download/v1.1.42/gopher64-windows-aarch64.exe'
$checksumArm64 = '1727e6da5db9284ebd1330aa7978399bd9a35e1776c7ec023b83270ec8a58835'

# Read the native OS architecture from the registry; $env:PROCESSOR_ARCHITECTURE
# reports AMD64 when this script runs under x64 emulation on an ARM64 machine.
$nativeArch = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').PROCESSOR_ARCHITECTURE

switch ($nativeArch) {
  'ARM64' { $url = $urlArm64; $checksum = $checksumArm64 }
  'AMD64' { $url = $urlX64;   $checksum = $checksumX64 }
  default { throw "Gopher64 provides Windows builds for x64 and ARM64 only (detected: $nativeArch)." }
}

Write-Host "Installing Gopher64 for $nativeArch"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileFullPath   = $exePath
  url64bit       = $url
  checksum64     = $checksum
  checksumType64 = 'sha256'
}
Get-ChocolateyWebFile @packageArgs

# Mark the shim as a GUI app so 'gopher64' returns immediately instead of
# waiting for the emulator window to close.
Set-Content -Path "$exePath.gui" -Value '' -Encoding Ascii

$shortcut = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'Gopher64.lnk'
Install-ChocolateyShortcut -ShortcutFilePath $shortcut -TargetPath $exePath -WorkingDirectory $toolsDir -Description 'Gopher64 N64 emulator'
