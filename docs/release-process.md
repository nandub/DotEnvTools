# Release Process

DotEnvTools uses manual releases while the project is pre-1.0.

## Current Policy

- Internal versions are recorded in `CHANGELOG.md`.
- GitHub Releases are the preferred place for pre-1.0 ZIP artifacts.
- PowerShell Gallery is the intended public publishing target when the module is ready for broader use.
- GitHub Packages is optional and only needed if a private or repository-scoped package feed is useful.
- Publishing remains manual until the release process is stable.

## Internal Version Flow

1. Update `Source\DotEnvTools.psd1`.
2. Update `CHANGELOG.md`.
3. Run quality checks:

```powershell
.\scripts\Test-DotEnvToolsQuality.ps1 -ModuleRoot . -RunAnalyzer -RunTests
```

4. Build the package:

```powershell
.\scripts\Build-DotEnvTools.ps1 -NewVersion 0.8.17 -Verbose
```

5. Commit the implementation.
6. Update the changelog entry with the implementation commit hash.
7. Commit the changelog hash update.

## Dev Container Feature Versioning

DotEnvTools has two related but separate versions:

- The PowerShell module version lives in `Source\DotEnvTools.psd1` and is selected by the Dev Container Feature `version` option.
- The Dev Container Feature version lives in `src\dotenvtools\devcontainer-feature.json` and is used in the GHCR reference, such as `ghcr.io/nandub/features/dotenvtools:0.1.0`.

Bump the module version when PowerShell module behavior, commands, docs, or release assets change.

Bump the Feature patch version when Feature packaging, install scripts, lifecycle hooks, defaults, or CI coverage change without changing the meaning of Feature options.

Bump the Feature minor version when Feature options are added, removed, renamed, or their behavior changes in a way consumers should consciously adopt.

Publish order:

1. Publish the DotEnvTools module GitHub Release ZIP.
2. Update the Feature default module version if needed.
3. Run the local Feature CI path.
4. Publish the Feature to GHCR.
5. Run the published Feature smoke workflow.

## Pre-1.0 GitHub Release Flow

Use GitHub Releases for internal or pre-1.0 distribution when a ZIP artifact should be easy to download.

Recommended manual steps:

1. Confirm CI is passing on `main`.
2. Build the ZIP locally or from CI.
3. Create a GitHub Release for the version.
4. Attach `dist\DotEnvTools-<version>.zip`.
5. Mark the release as prerelease until `1.0.0`.

Do not require tags for every internal version. Use tags when a version should become a durable release point.

## Public Publishing Flow

When the module is ready for public use:

1. Publish stable releases to PowerShell Gallery.
2. Keep GitHub Releases as the artifact and release-notes record.
3. Consider tag-triggered GitHub Release automation.
4. Keep PowerShell Gallery publishing manual until credentials, rollback behavior, and release approvals are settled.

## GitHub Packages

The existing GitHub Packages workflow is manual and optional. Keep it available for repository-scoped package-feed testing, but do not treat it as the primary public distribution channel.
