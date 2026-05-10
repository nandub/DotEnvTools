#!/usr/bin/env bash
set -euo pipefail

DOTENVTOOLS_VERSION="${VERSION:-0.8.16}"
INITIALIZE_PROJECT="${INITIALIZEPROJECT:-false}"
TEMPLATE="${TEMPLATE:-Basic}"
INCLUDE_VARIANTS="${INCLUDEVARIANTS:-false}"
ENVIRONMENT_NAME="${ENVIRONMENTNAME:-development}"

INSTALL_ROOT="/usr/local/share/powershell/Modules/DotEnvTools"
FEATURE_ROOT="/usr/local/share/dotenvtools"
ARCHIVE_URL="https://github.com/nandub/DotEnvTools/releases/download/v${DOTENVTOOLS_VERSION}/DotEnvTools-${DOTENVTOOLS_VERSION}.zip"
ARCHIVE_PATH="/tmp/dotenvtools-${DOTENVTOOLS_VERSION}.zip"
EXTRACT_ROOT="/tmp/dotenvtools-${DOTENVTOOLS_VERSION}"

echo "Installing DotEnvTools ${DOTENVTOOLS_VERSION}..."

if ! command -v pwsh >/dev/null 2>&1; then
    echo "DotEnvTools requires PowerShell. Add ghcr.io/devcontainers/features/powershell:2 before this Feature." >&2
    exit 1
fi

if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends ca-certificates curl unzip
    rm -rf /var/lib/apt/lists/*
elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache ca-certificates curl unzip
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y ca-certificates curl unzip
    dnf clean all
else
    echo "No supported package manager found. Install ca-certificates, curl, and unzip in the base image." >&2
    exit 1
fi

rm -rf "${EXTRACT_ROOT}" "${ARCHIVE_PATH}"
mkdir -p "${EXTRACT_ROOT}" "${INSTALL_ROOT}" "${FEATURE_ROOT}"

curl -fsSL "${ARCHIVE_URL}" -o "${ARCHIVE_PATH}"
unzip -q "${ARCHIVE_PATH}" -d "${EXTRACT_ROOT}"

MODULE_SOURCE="$(find "${EXTRACT_ROOT}" -type f -name 'DotEnvTools.psd1' -print -quit)"
if [ -z "${MODULE_SOURCE}" ]; then
    echo "Downloaded archive did not contain DotEnvTools.psd1." >&2
    exit 1
fi

MODULE_SOURCE_DIR="$(dirname "${MODULE_SOURCE}")"
rm -rf "${INSTALL_ROOT:?}/${DOTENVTOOLS_VERSION}"
mkdir -p "${INSTALL_ROOT}/${DOTENVTOOLS_VERSION}"
cp -R "${MODULE_SOURCE_DIR}/." "${INSTALL_ROOT}/${DOTENVTOOLS_VERSION}/"

cat > "${FEATURE_ROOT}/devcontainer-post-create.sh" << EOF
#!/usr/bin/env bash
set -euo pipefail

if [ "${INITIALIZE_PROJECT}" != "true" ]; then
    exit 0
fi

workspace="\${containerWorkspaceFolder:-\${PWD}}"

pwsh -NoLogo -NoProfile -Command "\
Import-Module '${INSTALL_ROOT}/${DOTENVTOOLS_VERSION}/DotEnvTools.psd1' -Force; \
\$params = @{ Path = '\${workspace}'; Template = '${TEMPLATE}'; EnvironmentName = '${ENVIRONMENT_NAME}' }; \
if ('${INCLUDE_VARIANTS}' -eq 'true') { \$params.IncludeVariants = \$true }; \
Initialize-DotEnvProject @params"
EOF

chmod +x "${FEATURE_ROOT}/devcontainer-post-create.sh"

pwsh -NoLogo -NoProfile -Command "Import-Module '${INSTALL_ROOT}/${DOTENVTOOLS_VERSION}/DotEnvTools.psd1' -Force; (Get-Module DotEnvTools).Version.ToString()"

rm -rf "${EXTRACT_ROOT}" "${ARCHIVE_PATH}"

echo "DotEnvTools ${DOTENVTOOLS_VERSION} installed."
