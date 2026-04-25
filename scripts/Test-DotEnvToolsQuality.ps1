<#!
.SYNOPSIS
Runs quality checks for DotEnvTools.
.DESCRIPTION
Validates source layout, manifest import, optional PSScriptAnalyzer, and optional Pester tests.
.PARAMETER ModuleRoot
Repository root.
.PARAMETER RunAnalyzer
Run PSScriptAnalyzer if available.
.PARAMETER RunTests
Run Pester tests if available.
.EXAMPLE
.\scripts\Test-DotEnvToolsQuality.ps1 -ModuleRoot .\ -Verbose
.EXAMPLE
.\scripts\Test-DotEnvToolsQuality.ps1 -ModuleRoot .\ -RunTests -Verbose
.INPUTS
None
.OUTPUTS
System.Management.Automation.PSCustomObject
.NOTES
Windows PowerShell 5.1 compatible.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
[OutputType([pscustomobject])]
param(
    [Parameter(Mandatory = $false)]
    [string]$ModuleRoot = '.',
    [Parameter(Mandatory = $false)]
    [switch]$RunAnalyzer,
    [Parameter(Mandatory = $false)]
    [switch]$RunTests
)

begin {
    $errors = New-Object System.Collections.ArrayList
    $warnings = New-Object System.Collections.ArrayList
}
process {
    $root = (Resolve-Path -Path $ModuleRoot).Path
    Write-Verbose "Using root path: $root"
    $manifestPath = Join-Path $root 'Source\DotEnvTools.psd1'
    if (-not (Test-Path $manifestPath)) { [void]$errors.Add("Manifest not found: $manifestPath") }
    else {
        try {
            Import-PowerShellDataFile -Path $manifestPath -ErrorAction Stop | Out-Null
            if ($PSCmdlet.ShouldProcess($manifestPath, 'Import module for validation')) {
                Remove-Module DotEnvTools -Force -ErrorAction SilentlyContinue
                Import-Module $manifestPath -Force -ErrorAction Stop
            }
        } catch { [void]$errors.Add("Module import failed: $($_.Exception.Message)") }
    }
    if ($RunAnalyzer) {
        $pssa = Get-Module -ListAvailable PSScriptAnalyzer | Sort-Object Version -Descending | Select-Object -First 1
        if ($pssa) {
            try {
                Import-Module $pssa.Path -Force -ErrorAction Stop
                $settings = Join-Path $root 'PSScriptAnalyzerSettings.psd1'
                if (Test-Path $settings) { $findings = Invoke-ScriptAnalyzer -Path (Join-Path $root 'Source') -Recurse -Settings $settings }
                else { $findings = Invoke-ScriptAnalyzer -Path (Join-Path $root 'Source') -Recurse }
                foreach ($finding in @($findings)) { [void]$warnings.Add("$($finding.RuleName): $($finding.Message)") }
            } catch { [void]$errors.Add("PSScriptAnalyzer failed: $($_.Exception.Message)") }
        } else { [void]$warnings.Add('PSScriptAnalyzer not installed.') }
    }
    if ($RunTests) {
        $testsPath = Join-Path $root 'Tests'
        $testFiles = @(Get-ChildItem -Path $testsPath -Filter '*.Tests.ps1' -Recurse -ErrorAction SilentlyContinue)
        if ($testFiles.Count -eq 0) { [void]$warnings.Add('No Pester test files found.') }
        else {
            $pester = Get-Module -ListAvailable Pester | Sort-Object Version -Descending | Select-Object -First 1
            if ($pester) {
                try {
                    Import-Module $pester.Path -Force -ErrorAction Stop
                    if ($PSCmdlet.ShouldProcess($testsPath, 'Execute Pester tests')) {
                        if ([version]$pester.Version -ge [version]'5.0.0') {
                            $config = New-PesterConfiguration
                            $config.Run.Path = $testsPath
                            $config.Run.PassThru = $true
                            $config.Output.Verbosity = 'Detailed'
                            $result = Invoke-Pester -Configuration $config
                        } else { $result = Invoke-Pester -Path $testsPath -PassThru }
                        if ($result.FailedCount -gt 0) { [void]$errors.Add("Pester failed tests: $($result.FailedCount)") }
                    }
                } catch { [void]$errors.Add("Pester failed: $($_.Exception.Message)") }
            } else { [void]$warnings.Add('Pester not installed.') }
        }
    }
}
end {
    foreach ($w in $warnings) { Write-Warning $w }
    foreach ($e in $errors) { Write-Error $e }
    [pscustomobject]@{ ModuleName='DotEnvTools'; Passed=(@($errors).Count -eq 0); ErrorCount=@($errors).Count; WarningCount=@($warnings).Count; RootPath=$ModuleRoot }
}
