# DotEnvTools

Windows PowerShell 5.1 compatible `.env` loader with explicit import/remove and opt-in auto-load.

## Quick start

```powershell
Import-Module .\Source\DotEnvTools.psd1 -Force
Import-DotEnvFile -Path .\.env -Verbose -PassThru
Enable-DotEnvAutoLoad -TrustedPath (Get-Location).Path -Verbose
```

## Build

```powershell
.\scripts\Build-DotEnvTools.ps1 -NewVersion 0.5.2 -Verbose
```
