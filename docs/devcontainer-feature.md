# Dev Container Feature

DotEnvTools includes an experimental Dev Container Feature under `src/dotenvtools`.

The Feature installs DotEnvTools into the container's PowerShell module path and can optionally create starter dotenv files after the workspace is available.

When `initializeProject` is `true`, the Feature creates starter files in `${containerWorkspaceFolder}` during the dev container lifecycle. Rebuild or recreate the dev container after changing Feature options, because the lifecycle script is generated during the Feature install step.

## Local Usage

Use the local Feature from this repository:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/powershell:2": {},
    "./src/dotenvtools": {
      "version": "0.8.17",
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
    "ghcr.io/nandub/features/dotenvtools:1": {
      "version": "0.8.17",
      "initializeProject": true,
      "template": "WebApp"
    }
  }
}
```

The Feature package is published by `.github/workflows/publish-devcontainer-feature.yml`. The package may need to be made public in GitHub package settings before it can be used outside the owner account.

## Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `version` | string | `0.8.17` | DotEnvTools module version to install from GitHub Releases. |
| `archivePath` | string | empty | Optional local ZIP path inside the Feature folder. Used for CI or local testing before a GitHub Release exists. |
| `initializeProject` | boolean | `false` | Create starter dotenv files after container creation. |
| `template` | string | `Basic` | Starter template. Supported values are `Basic` and `WebApp`. |
| `includeVariants` | boolean | `false` | Create `.env.local` and environment-specific variant files. |
| `environmentName` | string | `development` | Environment suffix for layered dotenv files. |

## Design Notes

- `install.sh` runs at image build time and installs the module from the GitHub Release ZIP.
- CI can set `archivePath` to install from a local ZIP copied into the Feature folder before the release exists.
- Project initialization runs from `postCreateCommand` and `postStartCommand`, because the workspace is reliably available after the container is created.
- The lifecycle commands pass `${containerWorkspaceFolder}` to the generated script as the first argument.
- The generated script skips initialization when `.env.example` already exists, so repeated starts do not rewrite existing dotenv files.
- The Feature expects PowerShell to be installed. Add `ghcr.io/devcontainers/features/powershell:2` before this Feature.
- The Feature targets Linux dev containers with PowerShell 7.

## Publishing Notes

Dev Container Features are published as OCI artifacts, usually to GitHub Container Registry.

Before publishing:

1. Confirm `src/dotenvtools/devcontainer-feature.json` has the intended Feature version.
2. Confirm the default DotEnvTools module version exists as a GitHub Release.
3. Run a local devcontainer build using the local Feature reference.
4. Run the `Publish Dev Container Feature` workflow manually, or push a `v*` tag after the workflow exists.
5. Mark the GHCR package public if the Feature should be discoverable outside the owner account.
