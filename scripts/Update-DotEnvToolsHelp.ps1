<#!
.SYNOPSIS
Generates DotEnvTools Markdown and external MAML help.
.DESCRIPTION
Uses PlatyPS to recreate command Markdown help under docs/reference from inline
comment-based help, then generates Source/<Locale>/DotEnvTools-help.xml for
Get-Help.
.PARAMETER ModuleRoot
Repository root.
.PARAMETER Locale
Help locale folder name.
.PARAMETER Force
Overwrites generated Markdown and external help.
.EXAMPLE
.\scripts\Update-DotEnvToolsHelp.ps1 -ModuleRoot . -Force
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
    [ValidateNotNullOrEmpty()]
    [string]$ModuleRoot = '.',

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Locale = 'en-US',

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

begin {
    function Import-DotEnvToolsPlatyPS {
        [CmdletBinding()]
        param()

        $module = Get-Module -ListAvailable -Name platyPS |
            Sort-Object Version -Descending |
            Select-Object -First 1

        if ($module) {
            Import-Module $module.Path -Force -ErrorAction Stop
            return
        }

        $installedModule = $null
        if (Get-Command -Name Get-InstalledModule -ErrorAction SilentlyContinue) {
            $installedModule = Get-InstalledModule -Name platyPS -ErrorAction SilentlyContinue
        }

        if ($installedModule -and $installedModule.InstalledLocation) {
            $manifestPath = Join-Path $installedModule.InstalledLocation 'platyPS.psd1'
            Import-Module $manifestPath -Force -ErrorAction Stop
            return
        }

        throw 'platyPS is required. Install it with: Install-Module platyPS -Scope CurrentUser'
    }
}

process {
    try {
        $root = (Resolve-Path -Path $ModuleRoot -ErrorAction Stop).Path
        $moduleName = 'DotEnvTools'
        $manifestPath = Join-Path $root "Source\$moduleName.psd1"
        $markdownRoot = Join-Path $root 'docs\reference'
        $externalHelpRoot = Join-Path $root "Source\$Locale"

        if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
            Write-Error "Manifest not found: $manifestPath"
            return
        }

        Import-DotEnvToolsPlatyPS

        Remove-Module $moduleName -Force -ErrorAction SilentlyContinue
        Import-Module $manifestPath -Force -ErrorAction Stop

        if (Test-Path -LiteralPath $markdownRoot -PathType Container) {
            if ($PSCmdlet.ShouldProcess($markdownRoot, 'Remove existing Markdown help folder')) {
                Remove-Item -LiteralPath $markdownRoot -Recurse -Force
            }
        }

        if ($PSCmdlet.ShouldProcess($markdownRoot, 'Create Markdown help folder')) {
            New-Item -Path $markdownRoot -ItemType Directory -Force | Out-Null
        }

        if (-not (Test-Path -LiteralPath $externalHelpRoot -PathType Container)) {
            if ($PSCmdlet.ShouldProcess($externalHelpRoot, 'Create external help folder')) {
                New-Item -Path $externalHelpRoot -ItemType Directory -Force | Out-Null
            }
        }

        if ($PSCmdlet.ShouldProcess($markdownRoot, 'Recreate Markdown help from module')) {
            New-MarkdownHelp `
                -Module $moduleName `
                -OutputFolder $markdownRoot `
                -AlphabeticParamsOrder `
                -Force:$Force `
                -ErrorAction Stop | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($externalHelpRoot, 'Generate external MAML help')) {
            New-ExternalHelp `
                -Path $markdownRoot `
                -OutputPath $externalHelpRoot `
                -Force `
                -ErrorAction Stop
        }
    }
    catch {
        Write-Error "Help generation failed: $($_.Exception.Message)"
    }
}

end {}
