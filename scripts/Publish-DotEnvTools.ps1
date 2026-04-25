<#
.SYNOPSIS
Publishes DotEnvTools to PowerShell Gallery.

.DESCRIPTION
Builds the requested DotEnvTools version if needed, validates the module manifest,
and publishes the versioned module package to PowerShell Gallery.

The PowerShell Gallery API key must be supplied through the current process
environment variable PSGALLERY_API_KEY.

.PARAMETER NewVersion
The module version to build and publish.

.EXAMPLE
$env:PSGALLERY_API_KEY = '<api-key>'
.\scripts\Publish-DotEnvTools.ps1 -NewVersion 0.7.0 -WhatIf

.EXAMPLE
$env:PSGALLERY_API_KEY = '<api-key>'
.\scripts\Publish-DotEnvTools.ps1 -NewVersion 0.7.0 -Verbose

.INPUTS
None.

.OUTPUTS
System.IO.FileInfo

.NOTES
Windows PowerShell 5.1 compatible.
Do not store PSGALLERY_API_KEY in source control, profile scripts, or committed files.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$NewVersion
)

begin {
    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = Split-Path -Parent $scriptRoot

    $moduleName = 'DotEnvTools'
    $buildScript = Join-Path $scriptRoot 'Build-DotEnvTools.ps1'
    $distRoot = Join-Path $repoRoot 'dist'
    $moduleVersionPath = Join-Path (Join-Path $distRoot $moduleName) $NewVersion
    $manifestPath = Join-Path $moduleVersionPath "$moduleName.psd1"

    $apiKey = $env:PSGALLERY_API_KEY
}

process {
    try {
        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Write-Error 'Set PSGALLERY_API_KEY for this session before publishing.'
            return
        }

        if (-not (Test-Path -Path $buildScript -PathType Leaf)) {
            Write-Error ("Build script not found: {0}" -f $buildScript)
            return
        }

        if (-not (Test-Path -Path $moduleVersionPath -PathType Container)) {
            if ($PSCmdlet.ShouldProcess($moduleVersionPath, "Build DotEnvTools $NewVersion")) {
                & $buildScript -NewVersion $NewVersion -Verbose:$VerbosePreference
            }
        }

        if (-not (Test-Path -Path $manifestPath -PathType Leaf)) {
            Write-Error ("Manifest not found after build: {0}" -f $manifestPath)
            return
        }

        Write-Verbose ("Validating manifest: {0}" -f $manifestPath)
        Test-ModuleManifest -Path $manifestPath -ErrorAction Stop | Out-Null

        if ($PSCmdlet.ShouldProcess($moduleVersionPath, 'Publish module to PowerShell Gallery')) {
            Publish-Module `
                -Path $moduleVersionPath `
                -NuGetApiKey $apiKey `
                -Verbose:$VerbosePreference
        }

        Get-Item -Path $moduleVersionPath
    }
    catch {
        Write-Error ("Publish failed. {0}" -f $_.Exception.Message)
    }
}

end {}