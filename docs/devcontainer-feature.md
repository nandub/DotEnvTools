# Dev Container Feature

DotEnvTools includes an experimental Dev Container Feature under `src/dotenvtools`.

The Feature installs DotEnvTools into the container's PowerShell module path and can optionally create starter dotenv files after the workspace is available.

## Local Usage

Use the local Feature from this repository:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/powershell:2": {},
    "./src/dotenvtools": {
      "version": "0.8.16",
      "initializeProject": true,
      "template": "WebApp",
      "includeVariants": true,
      "environmentName": "development"
    }
  }
}
```

## Published Usage

After publishing the Feature to GitHub Container Registry, use the GHCR reference:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/powershell:2": {},
    "ghcr.io/nandub/dotenvtools/dotenvtools:1": {
      "version": "0.8.16",
      "initializeProject": true,
      "template": "WebApp"
    }
  }
}
```

## Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `version` | string | `0.8.16` | DotEnvTools module version to install from GitHub Releases. |
| `initializeProject` | boolean | `false` | Create starter dotenv files after container creation. |
| `template` | string | `Basic` | Starter template. Supported values are `Basic` and `WebApp`. |
| `includeVariants` | boolean | `false` | Create `.env.local` and environment-specific variant files. |
| `environmentName` | string | `development` | Environment suffix for layered dotenv files. |

## Design Notes

- `install.sh` runs at image build time and installs the module from the GitHub Release ZIP.
- Project initialization runs from `postCreateCommand`, because the workspace is reliably available after the container is created.
- The Feature expects PowerShell to be installed. Add `ghcr.io/devcontainers/features/powershell:2` before this Feature.
- The Feature targets Linux dev containers with PowerShell 7.

## Publishing Notes

Dev Container Features are published as OCI artifacts, usually to GitHub Container Registry.

Before publishing:

1. Confirm `src/dotenvtools/devcontainer-feature.json` has the intended Feature version.
2. Confirm the default DotEnvTools module version exists as a GitHub Release.
3. Run a local devcontainer build using the local Feature reference.
4. Publish through a Feature registry workflow.
5. Mark GHCR packages public if the Feature should be discoverable.
