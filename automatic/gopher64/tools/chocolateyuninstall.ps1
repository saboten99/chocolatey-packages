$ErrorActionPreference = 'Stop'

# The exe and its shim are removed by Chocolatey along with the package folder.
$shortcut = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'Gopher64.lnk'
if (Test-Path $shortcut) {
  Remove-Item $shortcut -Force
}
