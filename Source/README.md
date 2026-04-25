# DotEnvTools 0.5.0

DotEnvTools is a Windows PowerShell 5.1-compatible module for reading, validating, importing, exporting, and auto-loading `.env` files.

## Usage

```powershell
Import-Module DotEnvTools -Force
Import-DotEnvFile -Path .\.env -Verbose
Read-DotEnvFile -Path .\.env
Test-DotEnvFile -Path .\.env -ExamplePath .\.env.example -Strict
```

## Auto-load for the current session

```powershell
Enable-DotEnvAutoLoad -TrustedPath 'C:\Projects' -RemoveOnExit -Verbose
Invoke-DotEnvAutoLoadNow -PassThru
Get-DotEnvAutoLoadState
Disable-DotEnvAutoLoad -RemoveCurrent
```

## Persistent profile integration

```powershell
Add-DotEnvAutoLoadProfile -TrustedPath 'C:\Projects' -RemoveOnExit -WhatIf
Add-DotEnvAutoLoadProfile -TrustedPath 'C:\Projects' -RemoveOnExit -Verbose
Remove-DotEnvAutoLoadProfile -WhatIf
```

## Masked output

```powershell
Import-DotEnvFile -Path .\.env -PassThru
Import-DotEnvFile -Path .\.env -PassThru -RevealValues
```

## Quality checks

Run the local quality gate from the package root:

```powershell
.\scripts\Test-DotEnvToolsQuality.ps1 -Verbose
```

Run optional analyzer and test checks when the modules are installed:

```powershell
.\scripts\Test-DotEnvToolsQuality.ps1 -RunPSScriptAnalyzer -RunPester -Verbose
```

Preview cleanup of generated artifacts:

```powershell
.\scripts\Test-DotEnvToolsQuality.ps1 -Clean -WhatIf
```
