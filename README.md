# Chocolatey Packages

[![Packages](https://github.com/saboten99/chocolatey-packages/actions/workflows/packages.yml/badge.svg)](https://github.com/saboten99/chocolatey-packages/actions/workflows/packages.yml)

Chocolatey packages maintained by saboten99.

| Package | Description |
|---|---|
| [gopher64](automatic/gopher64) | Gopher64, a cross-platform Nintendo 64 emulator |

## How it works

* `automatic/` holds packages kept up to date with [Chocolatey-AU](https://github.com/chocolatey-community/chocolatey-au). Each has an `update.ps1` that finds the latest upstream release and a `test.ps1` used by CI.
* The [Packages workflow](.github/workflows/packages.yml) runs on Windows:
  * on every push / pull request it packs each package and tests install and uninstall;
  * daily it checks for new upstream versions, tests them, commits the bump and, if the `CHOCO_API_KEY` repository secret is set, pushes the new version to the Chocolatey community repository.
* To publish the current versions by hand, run the workflow from the Actions tab with **publish** ticked.

## Local use

```powershell
cd automatic\gopher64
choco pack
choco install gopher64 --source . -y

# check for a new upstream version (needs: choco install chocolatey-au)
.\update.ps1
```
