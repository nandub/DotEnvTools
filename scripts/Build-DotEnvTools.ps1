<#!
.SYNOPSIS
Builds a deployable DotEnvTools module package.
.DESCRIPTION
Creates a versioned PowerShell module layout under .\dist from the Source folder, then creates a deployable ZIP package.
.PARAMETER NewVersion
Optional module version to stamp into the manifest before packaging.
.EXAMPLE
.\scripts\Build-DotEnvTools.ps1 -WhatIf
.EXAMPLE
.\scripts\Build-DotEnvTools.ps1 -NewVersion 0.5.2 -Verbose
.INPUTS
None
.OUTPUTS
System.IO.FileInfo
.NOTES
Windows PowerShell 5.1 compatible.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
[OutputType([System.IO.FileInfo])]
param(
    [Parameter(Mandatory = $false)]
    [string]$NewVersion
)

begin {
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = Split-Path -Parent $scriptPath
    $moduleName = 'DotEnvTools'
    $sourceRoot = Join-Path $repoRoot 'Source'
    $manifestPath = Join-Path $sourceRoot "$moduleName.psd1"
    $modulePath = Join-Path $sourceRoot "$moduleName.psm1"
    $distRoot = Join-Path $repoRoot 'dist'
}

process {
    try {
        if (-not (Test-Path $manifestPath)) { Write-Error "Manifest not found: $manifestPath"; return }
        if (-not (Test-Path $modulePath)) { Write-Error "Module file not found: $modulePath"; return }

        if ($NewVersion) {
            $manifest = Import-PowerShellDataFile -Path $manifestPath
            $currentVersion = [string]$manifest.ModuleVersion
            
            if ($currentVersion -ne $NewVersion) {
                if ($PSCmdlet.ShouldProcess($manifestPath, "Update ModuleVersion from $currentVersion to $NewVersion")) {
                    $manifestText = Get-Content -Path $manifestPath -Raw -ErrorAction Stop
                    $updatedText = $manifestText -replace "ModuleVersion\s*=\s*'[^']+'", "ModuleVersion = '$NewVersion'"

                    if ($updatedText -ne $manifestText) {
                        [System.IO.File]::WriteAllText(
                            $manifestPath,
                            $updatedText,
                            [System.Text.UTF8Encoding]::new($false)
                        )
                    }
                }
            } else {
                Write-Verbose ("ModuleVersion is already {0}; manifest update skipped." -f $NewVersion)
            }
        }

        $manifest = Import-PowerShellDataFile -Path $manifestPath
        $version = [string]$manifest.ModuleVersion
        $stagingRoot = Join-Path $distRoot $moduleName
        $versionRoot = Join-Path $stagingRoot $version
        $zipPath = Join-Path $distRoot "$moduleName-$version.zip"

        if (Test-Path $stagingRoot) {
            if ($PSCmdlet.ShouldProcess($stagingRoot, 'Remove previous staging folder')) {
                Remove-Item -Path $stagingRoot -Recurse -Force
            }
        }
        if ($PSCmdlet.ShouldProcess($versionRoot, 'Create module staging folder')) {
            New-Item -Path $versionRoot -ItemType Directory -Force | Out-Null
        }
        if ($PSCmdlet.ShouldProcess($versionRoot, 'Copy Source files')) {
            Copy-Item -Path (Join-Path $sourceRoot '*') -Destination $versionRoot -Recurse -Force
        }
        foreach ($file in @('README.md','CHANGELOG.md','LICENSE')) {
            $sourceFile = Join-Path $repoRoot $file
            if (Test-Path $sourceFile) {
                if ($PSCmdlet.ShouldProcess($versionRoot, "Copy $file")) {
                    Copy-Item -Path $sourceFile -Destination $versionRoot -Force
                }
            }
        }
        if (Test-Path $zipPath) {
            if ($PSCmdlet.ShouldProcess($zipPath, 'Remove previous ZIP')) { Remove-Item -Path $zipPath -Force }
        }
        if ($PSCmdlet.ShouldProcess($zipPath, 'Create deployment ZIP')) {
            Compress-Archive -Path $stagingRoot -DestinationPath $zipPath -Force
            Get-Item -Path $zipPath
        }
    }
    catch { Write-Error "Build failed: $($_.Exception.Message)" }
}
end { }
