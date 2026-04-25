# DotEnvTools

DotEnvTools is a Windows PowerShell 5.1-compatible module for reading, importing, removing, exporting, validating, and auto-loading `.env` files.

It is designed for safe local development workflows where project-specific environment variables load into the current PowerShell process without permanently modifying User or Machine environment variables.

## Features

- Parse `.env` content safely without `Invoke-Expression`
- Import `.env` variables into the current process
- Remove or restore variables loaded from a `.env` file
- Preserve existing variables by default unless `-Override` is used
- Mask imported values in output by default
- Validate `.env` syntax and optional `.env.example` coverage
- Export process environment variables to `.env` format
- Read values without mutating the process environment
- Add, update, and remove keys in dotenv files
- Run commands with temporary dotenv values
- Auto-load `.env` files when entering trusted directories
- Optionally remove auto-loaded variables when leaving a project directory
- Search parent directories for dotenv files
- Check `.gitignore` hygiene for dotenv secret files
- Reload unchanged `.env` files when tracked variables are missing
- Layered dotenv loading:
  - `.env`
  - `.env.local`
  - `.env.<EnvironmentName>`
  - `.env.<EnvironmentName>.local`
- Opt-in `${NAME}` variable expansion
- PowerShell 5.1 compatible
- Pester test coverage
- PSScriptAnalyzer-compatible project layout

## Installation From Source

From the repository root:

```powershell
Import-Module .\Source\DotEnvTools.psd1 -Force
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

Remove variables loaded from the file:

```powershell
Remove-DotEnvVariable -Path .\.env -Verbose
```

`Remove-DotEnvVariable` only removes or restores variables that DotEnvTools previously loaded. Existing variables skipped by the default no-clobber behavior are left unchanged.

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

When DotEnvTools overwrites a value, removal restores the original process value when it is still tracked.

## PassThru Output

By default, non-empty values are masked:

```powershell
Import-DotEnvFile -Path .\.env -PassThru
```

Reveal values explicitly:

```powershell
Import-DotEnvFile -Path .\.env -PassThru -RevealValues
```

## Variable Expansion

Variable expansion is opt-in. DotEnvTools expands `${NAME}` and `$NAME` references from values already seen in the dotenv load order, then from the current process environment. Missing references are preserved as written.

Example `.env`:

```dotenv
HOST=localhost
PORT=8080
API_URL=http://${HOST}:${PORT}
ALT_URL=http://$HOST:$PORT
LITERAL_VALUE=${MISSING_VALUE}
```

Import with expansion:

```powershell
Import-DotEnvFile -Path .\.env -ExpandVariables -Override
```

Result:

```powershell
$env:API_URL
# http://localhost:8080

$env:LITERAL_VALUE
# ${MISSING_VALUE}
```

## Layered Dotenv Loading

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

Without `-Override`, the first loaded value wins because no-clobber behavior is the default.

## Resolve Dotenv Files

Use `Get-DotEnvFilePath` to see which files would be loaded:

```powershell
Get-DotEnvFilePath -Path . -IncludeVariants -EnvironmentName development
```

Only existing files are returned.

Search parent directories:

```powershell
Find-DotEnvFile -Path . -IncludeVariants -EnvironmentName development
Get-DotEnvFilePath -Path . -SearchUp
```

When `-SearchUp` is used, parent directories are returned before child directories so child/project values can override parent values when `-Override` is used.

## Read Values Without Importing

Read all values as an object:

```powershell
Read-DotEnvMap -Path .\.env
```

Read values as an ordered hashtable:

```powershell
Read-DotEnvMap -Path . -IncludeVariants -EnvironmentName development -AsHashtable
```

Read one value:

```powershell
Get-DotEnvValue -Path .\.env -Name API_URL
```

These commands do not modify `Env:`.

## Edit Dotenv Files

Add or update a key:

```powershell
Set-DotEnvValue -Path .\.env -Name API_URL -Value https://localhost:8443
```

Create a missing file while setting a key:

```powershell
Set-DotEnvValue -Path .\.env -Name API_URL -Value https://localhost:8443 -Force
```

Remove a key:

```powershell
Remove-DotEnvValue -Path .\.env -Name API_URL
```

Unrelated comments and keys are preserved.

## Run Commands

Run a command with dotenv values applied temporarily:

```powershell
Invoke-DotEnvCommand -Path .\.env -Command npm -ArgumentList @('test') -Override
```

DotEnvTools restores previous process environment values after the command returns.

## Validation

Validate `.env` syntax:

```powershell
Test-DotEnvFile -Path .\.env
```

Validate syntax and check that keys from `.env.example` exist in `.env`:

```powershell
Test-DotEnvFile -Path .\.env -ExamplePath .\.env.example
```

Require specific keys and warn on keys that are not present in the example file:

```powershell
Test-DotEnvFile `
    -Path .\.env `
    -ExamplePath .\.env.example `
    -Required API_URL,DB_NAME `
    -RequireNoExtraKeys
```

Malformed lines are reported in the returned `Errors` collection and set `IsValid` to `False`.

## Export

Export selected process environment variables:

```powershell
Export-DotEnvFile -Path .\.env.export -Name API_URL,DB_NAME -Force
```

Exported values containing whitespace, `#`, `=`, or embedded double quotes are quoted as needed. Double-quoted values round-trip through `ConvertFrom-DotEnv`.

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

Remove loaded variables when leaving a project directory:

```powershell
Enable-DotEnvAutoLoad -TrustedPath C:\Projects -RemoveOnExit -Verbose
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

Disable auto-load and remove currently loaded variables:

```powershell
Disable-DotEnvAutoLoad -RemoveCurrent -Verbose
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

## Preview Changes With WhatIf

```powershell
Import-DotEnvFile -Path .\.env -WhatIf
Remove-DotEnvVariable -Path .\.env -WhatIf
Enable-DotEnvAutoLoad -TrustedPath C:\Projects -WhatIf
Set-DotEnvValue -Path .\.env -Name API_URL -Value https://localhost -WhatIf
Remove-DotEnvValue -Path .\.env -Name API_URL -WhatIf
```

## Gitignore Hygiene

Check whether common dotenv secret files are ignored:

```powershell
Test-DotEnvGitIgnore -Path .
```

By default this checks for `.env`, `.env.*`, and `.env.keys`.

## Build Deployable Package

```powershell
.\scripts\Build-DotEnvTools.ps1 -NewVersion 0.8.0 -Verbose
```

This creates:

```text
dist\DotEnvTools\0.8.0\
dist\DotEnvTools-0.8.0.zip
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
```

## Security Notes

DotEnvTools treats `.env` files as data.

It does not:

- execute commands
- use `Invoke-Expression`
- perform command substitution
- modify User or Machine environment variables
- override TLS validation
- store credentials

Auto-load should be enabled only for trusted project directories.

## Public Commands

```text
Add-DotEnvAutoLoadProfile
ConvertFrom-DotEnv
Disable-DotEnvAutoLoad
Enable-DotEnvAutoLoad
Export-DotEnvFile
Find-DotEnvFile
Get-DotEnvAutoLoadState
Get-DotEnvFilePath
Get-DotEnvValue
Import-DotEnvFile
Invoke-DotEnvCommand
Invoke-DotEnvAutoLoadNow
Read-DotEnvMap
Read-DotEnvFile
Remove-DotEnvAutoLoadProfile
Remove-DotEnvValue
Remove-DotEnvVariable
Set-DotEnvValue
Test-DotEnvGitIgnore
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
