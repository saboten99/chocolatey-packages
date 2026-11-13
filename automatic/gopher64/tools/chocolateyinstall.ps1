$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exePath  = Join-Path $toolsDir 'gopher64.exe'

$urlX64      = 'https://github.com/gopher64/gopher64/releases/download/v1.2.1/gopher64-windows-x86_64.exe'
$checksumX64 = '6aa70afb9e168e6d0159cc676332ea36c55aa947082590383c35db072359926b'

$urlArm64      = 'https://github.com/gopher64/gopher64/releases/download/v1.2.1/gopher64-windows-aarch64.exe'
$checksumArm64 = 'c500dc062f949e34fdd5301d67dcd7d3d97f31efb1ea77ae7d529ec94a06a3cc'

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
