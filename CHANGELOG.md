# \# Changelog

# 

# All notable changes to this project will be documented in this file.

# 

# This project follows a pragmatic versioning approach:

# 

# \- 0.5.x → stabilization and core functionality

# \- 0.6.x → feature expansion (layering)

# \- 1.0.0 → production-ready public release

# 

# \---

# 

# \## \[0.6.0] - 2026-04-25

# 

# \### Added

# \- Layered `.env` file support:

# &#x20; - `.env`

# &#x20; - `.env.local`

# &#x20; - `.env.<EnvironmentName>`

# &#x20; - `.env.<EnvironmentName>.local`

# \- New `Get-DotEnvFilePath` function for deterministic `.env` resolution

# \- Pester tests for layered loading and precedence behavior

# 

# \### Changed

# \- `Import-DotEnvFile`, `Remove-DotEnvVariable`, and `Invoke-DotEnvAutoLoadNow`

# &#x20; now use `Get-DotEnvFilePath` for file resolution

# \- Standardized load order across all operations

# \- Updated README with layered usage examples

# 

# \### Fixed

# \- Correct handling of file precedence with `-Override` and `-NoClobber`

# \- Eliminated parameter contract drift between functions

# 

# \---

# 

# \## \[0.5.2] - 2026-04-25

# 

# \### Added

# \- Stable Pester test suite for:

# &#x20; - parsing

# &#x20; - import/remove lifecycle

# &#x20; - auto-load regression behavior

# 

# \### Changed

# \- Normalized data flow:

# &#x20; - `ConvertFrom-DotEnv` → object

# &#x20; - `Read-DotEnvFile` → Name/Value records

# \- Updated module structure to use `.psd1` as the single export contract

# \- Improved test reliability for empty values

# 

# \### Fixed

# \- Fixed auto-load bug where unchanged `.env` files were not reloaded when variables were missing

# \- Fixed `$null` vs `''` handling for empty values (`EMPTY\_VALUE=`)

# \- Fixed integration issues between parser, reader, and import pipeline

# \- Fixed `Remove-DotEnvVariable` state tracking (`HadPreviousValue`)

# \- Fixed multiple parameter mismatches (`-EnvironmentName`, `-IncludeVariants`, etc.)

# 

# \---

# 

# \## \[0.5.1] - 2026-04-25

# 

# \### Fixed

# \- Auto-load logic now reloads `.env` files when variables are missing even if file hash is unchanged

# \- Improved tracking of loaded variables per file

# 

# \---

# 

# \## \[0.5.0] - 2026-04-25

# 

# \### Added

# \- Initial working implementation of DotEnvTools

# \- Core functions:

# &#x20; - `ConvertFrom-DotEnv`

# &#x20; - `Read-DotEnvFile`

# &#x20; - `Import-DotEnvFile`

# &#x20; - `Remove-DotEnvVariable`

# \- Auto-load system:

# &#x20; - `Enable-DotEnvAutoLoad`

# &#x20; - `Disable-DotEnvAutoLoad`

# &#x20; - `Invoke-DotEnvAutoLoadNow`

# \- Profile integration:

# &#x20; - `Add-DotEnvAutoLoadProfile`

# &#x20; - `Remove-DotEnvAutoLoadProfile`

# \- Build system:

# &#x20; - `Build-DotEnvTools.ps1`

# \- Quality checks:

# &#x20; - `Test-DotEnvToolsQuality.ps1`

# 

# \### Notes

# \- Initial version exposed several integration issues that were resolved in later releases

