# Changelog

All notable changes to this project will be documented in this file.

This project follows a pragmatic versioning approach:

- 0.5.x: stabilization and core functionality
- 0.6.x: feature expansion with layered dotenv loading
- 0.7.x: variable expansion and behavior hardening
- 0.8.x: workflow helpers and parser compatibility
- 1.0.0: production-ready public release

---

## [0.8.8] - 2026-04-25

Internal version commit: pending.

### Fixed

- Fixed Linux CI failures where commands wrote hidden `.env*` files successfully but failed when returning `Get-Item` results without `-Force`.
- Updated `Remove-DotEnvValue` to use the same cross-platform target path resolver as other dotenv file write commands.

## [0.8.7] - 2026-04-25

Internal version commit: `cceffa8`.

### Fixed

- Fixed cross-platform writes to new dotenv files on Linux runners by resolving parent directories instead of non-existent target files.

## [0.8.6] - 2026-04-25

Internal version commit: `59f8c62`.

### Added

- Added GitHub `ProjectUri` and `LicenseUri` metadata to the module manifest.
- Added a CI workflow for quality checks, build validation, and smoke import.
- Made the GitHub Packages publish workflow manual-only with an explicit version input.

## [0.8.5] - 2026-04-25

Internal version commit: `9e89d14`.

### Fixed

- Fixed `Test-DotEnvFile` so omitting `-Required` does not add an invalid empty required-key error.

## [0.8.4] - 2026-04-25

Internal version commit: `8f967ec`.

### Documentation

- Normalized comment-based help blocks so all exported commands surface synopsis and parameter help through `Get-Help`.
- Expanded help coverage for newer public commands and validation options.

## [0.8.3] - 2026-04-25

Internal version commit: `19e825a`.

### Added

- Added `New-DotEnvFile` to create `.env`, `.env.example`, and optional layered dotenv starter files for new projects.
- Added a repository `.env.example` template for local smoke testing.

### Changed

- Updated `.gitignore` to keep ignoring real `.env*` files while allowing `.env.example` templates.

## [0.8.2] - 2026-04-25

Internal version commit: `336a948`.

### Documentation

- Added a README quick-start section for common import, command, read-only, validation, and auto-load workflows.
- Documented help authoring practice and comment-based help as the current source of truth.
- Removed the empty placeholder external MAML help file.

## [0.8.1] - 2026-04-25

Internal version commit: `9eef89d`.

### Fixed

- Hardened quoted value parsing so `#` inside quotes is preserved and comments after quoted values are ignored.
- Reported unterminated quoted values as strict parser errors instead of treating them as literal values.
- Added regression coverage for repeated keys and command environment restoration after nonzero command exits.

## [0.8.0] - 2026-04-25

Internal version commit: `e3f82ae`.

### Added

- Added `Invoke-DotEnvCommand` to run commands with dotenv values applied temporarily.
- Added parse-only value APIs: `Read-DotEnvMap` and `Get-DotEnvValue`.
- Added dotenv file editing commands: `Set-DotEnvValue` and `Remove-DotEnvValue`.
- Added `Find-DotEnvFile` and `-SearchUp` support for parent-directory discovery.
- Added `Test-DotEnvGitIgnore` for simple dotenv secret hygiene checks.
- Added stricter validation options through `Test-DotEnvFile -Required` and `-RequireNoExtraKeys`.

### Changed

- Expanded parser compatibility for `export KEY=value`, safe inline comments, unbraced `$VAR` expansion, common double-quote escapes, and quoted multiline values.

## [0.7.1] - 2026-04-25

Internal version commit: `08969dd` (`fc9fd0d` introduced the behavior fixes).

### Fixed

- Prevented `Remove-DotEnvVariable` and `RemoveOnExit` cleanup from removing pre-existing variables that were skipped by default no-clobber imports.
- Made `Test-DotEnvFile` report strict parser errors through its returned `Errors` collection and set `IsValid` to `False` for malformed dotenv files.
- Preserved embedded double quotes when exporting and parsing double-quoted values.
- Preserved dotenv file order during parsing so opt-in variable expansion is deterministic.
- Returned the actual removal state from `Disable-DotEnvAutoLoad -RemoveCurrent`.

### Documentation

- Rebuilt the README with current usage for validation, export, variable expansion, auto-load cleanup, and quality checks.
- Updated known issues and design notes for the current parser behavior.

## [0.7.0] - 2026-04-25

Internal version commit: `f3119bd`.

### Added

- Added opt-in variable expansion using `${NAME}` syntax.
- Added expansion support to `Import-DotEnvFile` through `-ExpandVariables`.
- Added tests for default raw behavior, expanded values, and missing references.

### Security

- Expansion is text-only and does not execute commands.
- Missing references are preserved unchanged.

## [0.6.0] - 2026-04-25

Internal version commit: `647435b`.

### Added

- Added layered `.env` file support:
  - `.env`
  - `.env.local`
  - `.env.<EnvironmentName>`
  - `.env.<EnvironmentName>.local`
- Added `Get-DotEnvFilePath` for deterministic `.env` resolution.
- Added Pester tests for layered loading and precedence behavior.

### Changed

- Updated `Import-DotEnvFile`, `Remove-DotEnvVariable`, and `Invoke-DotEnvAutoLoadNow` to use `Get-DotEnvFilePath` for file resolution.
- Standardized load order across dotenv operations.
- Updated the README with layered usage examples.

### Fixed

- Corrected file precedence behavior with `-Override` and `-NoClobber`.
- Eliminated parameter contract drift between functions.

## [0.5.2] - 2026-04-25

Internal version commit: `9efd6a3`.

### Added

- Added stable Pester coverage for parsing, import/remove lifecycle, and auto-load regression behavior.

### Changed

- Normalized parser and reader data flow through `ConvertFrom-DotEnv` and `Read-DotEnvFile`.
- Updated module structure to use `.psd1` as the single export contract.
- Improved test reliability for empty values.

### Fixed

- Fixed auto-load reload behavior when tracked variables are missing and file hashes are unchanged.
- Fixed `$null` vs empty-string handling for `EMPTY_VALUE=`.
- Fixed integration issues between parser, reader, and import pipeline.
- Fixed `Remove-DotEnvVariable` state tracking for previous values.
- Fixed parameter mismatches around `-EnvironmentName` and `-IncludeVariants`.

## [0.5.1] - 2026-04-25

Internal version commit: `9efd6a3` (retrospective changelog entry first appeared in `647435b`).

### Fixed

- Reloaded `.env` files when variables are missing even if the file hash is unchanged.
- Improved tracking of loaded variables per file.

## [0.5.0] - 2026-04-25

Internal version commit: `9efd6a3` (retrospective changelog entry first appeared in `647435b`).

### Added

- Added initial working implementation of DotEnvTools.
- Added parser, reader, importer, and remover commands.
- Added auto-load and profile integration commands.
- Added build and quality check scripts.

### Notes

- Initial version exposed several integration issues that were resolved in later releases.
