# Auto-update script for Chocolatey-AU (https://github.com/chocolatey-community/chocolatey-au)
# Usage:  Install-Module Chocolatey-AU ; cd gopher64 ; .\update.ps1
Import-Module Chocolatey-AU

function global:au_GetLatest {
  $headers = @{ 'User-Agent' = 'chocolatey-packages-au' }
  if ($env:GITHUB_TOKEN) { $headers.Authorization = "Bearer $env:GITHUB_TOKEN" }  # avoids API rate limits in CI
  $release = Invoke-RestMethod -UseBasicParsing -Headers $headers 'https://api.github.com/repos/gopher64/gopher64/releases/latest'
  $tag     = $release.tag_name
  $version = $tag.TrimStart('v')

  $x64   = $release.assets | Where-Object name -eq 'gopher64-windows-x86_64.exe'
  $arm64 = $release.assets | Where-Object name -eq 'gopher64-windows-aarch64.exe'
  if (-not $x64 -or -not $arm64) { throw "Windows assets not found in release $tag" }

  @{
    Version      = $version
    Tag          = $tag
    URL64        = $x64.browser_download_url
    URLArm64     = $arm64.browser_download_url
    ReleaseNotes = $release.html_url
  }
}

function global:au_BeforeUpdate {
  # AU only hashes URL/URL64 itself; hash both binaries here.
  $Latest.Checksum64    = Get-RemoteChecksum $Latest.URL64 -Algorithm sha256
  $Latest.ChecksumArm64 = Get-RemoteChecksum $Latest.URLArm64 -Algorithm sha256
}

function global:au_SearchReplace {
  @{
    'tools\chocolateyinstall.ps1' = @{
      "(?i)(^\s*\`$urlX64\s*=\s*)'.*'"        = "`$1'$($Latest.URL64)'"
      "(?i)(^\s*\`$checksumX64\s*=\s*)'.*'"   = "`$1'$($Latest.Checksum64)'"
      "(?i)(^\s*\`$urlArm64\s*=\s*)'.*'"      = "`$1'$($Latest.URLArm64)'"
      "(?i)(^\s*\`$checksumArm64\s*=\s*)'.*'" = "`$1'$($Latest.ChecksumArm64)'"
    }
    'gopher64.nuspec' = @{
      '(<releaseNotes>).*(</releaseNotes>)' = "`${1}$($Latest.ReleaseNotes)`${2}"
    }
  }
}

update -ChecksumFor none
