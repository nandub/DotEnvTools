# DotEnvTools

DotEnvTools is a Windows PowerShell 5.1-compatible module for reading, importing, removing, exporting, and auto-loading `.env` files.

It is designed for safe local development workflows where project-specific environment variables should load into the current PowerShell process without permanently modifying User or Machine environment variables.

## Features

- Parse `.env` content safely without `Invoke-Expression`
- Import `.env` variables into the current process
- Remove variables defined by a `.env` file
- Preserve existing variables unless `-Override` is used
- Mask values in output by default
- Auto-load `.env` files when entering trusted directories
- Reload unchanged `.env` files when tracked variables are missing
- Layered dotenv loading:
  - `.env`
  - `.env.local`
  - `.env.<EnvironmentName>`
  - `.env.<EnvironmentName>.local`
- PowerShell 5.1 compatible
- Pester test coverage
- PSScriptAnalyzer-compatible project layout

## Repository Layout

```text
DotEnvTools\
  Source\
    DotEnvTools.psd1
    DotEnvTools.psm1
    en-US\
      DotEnvTools-help.xml
  Tests\
    DotEnvTools.Tests.ps1
  scripts\
    Build-DotEnvTools.ps1
    Test-DotEnvToolsQuality.ps1
  CHANGELOG.md
  LICENSE
  PSScriptAnalyzerSettings.psd1
  README.md
````

## Installation from Source

From the repository root:

```powershell
Import-Module .\Source\DotEnvTools.psd1 -Force
```

## Build Deployable Package

```powershell
.\scripts\Build-DotEnvTools.ps1 -NewVersion 0.6.0 -Verbose
```

This creates:

```text
dist\DotEnvTools\0.6.0\
dist\DotEnvTools-0.6.0.zip
```

## Run Quality Checks

Basic validation:

```powershell
.\scripts\Test-DotEnvToolsQuality.ps1 -ModuleRoot .\ -Verbose
```

Run tests:

```powershell
.\scripts\Test-DotEnvToolsQuality.ps1 -ModuleRoot .\ -RunTests -Verbose
```

Run tests and PSScriptAnalyzer:

```powershell
.\scripts\Test-DotEnvToolsQuality.ps1 -ModuleRoot .\ -RunAnalyzer -RunTests -Verbose
```

## Basic Usage

Create a `.env` file:

```dotenv
API_URL=https://localhost:8443
DB_NAME=DotEnvDemo
QUOTED_VALUE="hello world"
EMPTY_VALUE=
```

Import it:

```powershell
Import-DotEnvFile -Path .\.env -Verbose
```

View values:

```powershell
$env:API_URL
$env:DB_NAME
$env:QUOTED_VALUE
```

Remove variables defined in the file:

```powershell
Remove-DotEnvVariable -Path .\.env -Verbose
```

## Preview Changes with WhatIf

```powershell
Import-DotEnvFile -Path .\.env -WhatIf
Remove-DotEnvVariable -Path .\.env -WhatIf
Enable-DotEnvAutoLoad -TrustedPath C:\Projects -WhatIf
```

## PassThru Output

By default, non-empty values are masked:

```powershell
Import-DotEnvFile -Path .\.env -PassThru
```

Reveal values explicitly:

```powershell
Import-DotEnvFile -Path .\.env -PassThru -RevealValues
```

## Override Behavior

By default, existing environment variables are not overwritten.

```powershell
Import-DotEnvFile -Path .\.env
```

To overwrite existing values:

```powershell
Import-DotEnvFile -Path .\.env -Override
```

To explicitly preserve existing values:

```powershell
Import-DotEnvFile -Path .\.env -NoClobber
```

## Layered Dotenv Loading

DotEnvTools 0.6.0 supports layered loading.

Given this directory:

```text
.env
.env.local
.env.development
.env.development.local
```

Run:

```powershell
Import-DotEnvFile -Path . -IncludeVariants -EnvironmentName development -Override
```

Load order:

```text
.env
.env.local
.env.development
.env.development.local
```

Later files win when `-Override` is used.

Example:

```dotenv
# .env
SHARED_VALUE=base
```

```dotenv
# .env.local
SHARED_VALUE=local
```

```dotenv
# .env.development
SHARED_VALUE=development
```

```dotenv
# .env.development.local
SHARED_VALUE=development-local
```

Result:

```powershell
$env:SHARED_VALUE
# development-local
```

Without `-Override`, the first value wins because `-NoClobber` behavior is the default.

## Resolve Dotenv Files

Use `Get-DotEnvFilePath` to see which files would be loaded:

```powershell
Get-DotEnvFilePath -Path . -IncludeVariants -EnvironmentName development
```

Expected order:

```text
.env
.env.local
.env.development
.env.development.local
```

Only existing files are returned.

## Auto-Load

Enable auto-load for a trusted path:

```powershell
Enable-DotEnvAutoLoad -TrustedPath C:\Projects -Verbose
```

Enable layered auto-load:

```powershell
Enable-DotEnvAutoLoad `
    -TrustedPath C:\Projects `
    -IncludeVariants `
    -EnvironmentName development `
    -Verbose
```

Run auto-load immediately:

```powershell
Invoke-DotEnvAutoLoadNow -Verbose
```

Inspect state:

```powershell
Get-DotEnvAutoLoadState
```

Disable auto-load:

```powershell
Disable-DotEnvAutoLoad -Verbose
```

## Profile Integration

Add auto-load to the current user profile:

```powershell
Add-DotEnvAutoLoadProfile -TrustedPath C:\Projects -WhatIf
Add-DotEnvAutoLoadProfile -TrustedPath C:\Projects
```

Remove it:

```powershell
Remove-DotEnvAutoLoadProfile -WhatIf
Remove-DotEnvAutoLoadProfile
```

## Security Notes

DotEnvTools treats `.env` files as data.

It does not:

* execute commands
* use `Invoke-Expression`
* perform command substitution
* modify User or Machine environment variables
* override TLS validation
* store credentials

Auto-load should be enabled only for trusted project directories.

## Public Commands

```text
Add-DotEnvAutoLoadProfile
ConvertFrom-DotEnv
Disable-DotEnvAutoLoad
Enable-DotEnvAutoLoad
Export-DotEnvFile
Get-DotEnvAutoLoadState
Get-DotEnvFilePath
Import-DotEnvFile
Invoke-DotEnvAutoLoadNow
Read-DotEnvFile
Remove-DotEnvAutoLoadProfile
Remove-DotEnvVariable
Test-DotEnvFile
```

## Export Model

DotEnvTools uses the module manifest as the public export contract.

```text
Source\DotEnvTools.psd1   = public exported functions
Source\DotEnvTools.psm1   = implementation
```

Do not use `Export-ModuleMember` in the `.psm1`.

Update `FunctionsToExport` in the manifest when adding or removing public commands.

## License

MIT

````

After replacing it, delete the duplicate:

```powershell
Remove-Item .\Source\README.md -Force
````

Then run:

```powershell
.\scripts\Test-DotEnvToolsQuality.ps1 -ModuleRoot .\ -RunTests -Verbose
.\scripts\Build-DotEnvTools.ps1 -NewVersion 0.6.0 -Verbose
```

