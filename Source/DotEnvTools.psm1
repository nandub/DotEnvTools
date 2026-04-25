# DotEnvTools.psm1
# Windows PowerShell 5.1 compatible .env loader.

Set-StrictMode -Version 2.0

$dotEnvStateVariable = Get-Variable -Name DotEnvState -Scope Script -ErrorAction SilentlyContinue
if ($null -eq $dotEnvStateVariable) {
    $script:DotEnvState = @{
        AutoLoadEnabled = $false
        LastPath = $null
        LastLoadedFiles = @()
        LoadedFiles = @{}
        LoadedVariables = @{}
        OriginalValues = @{}
        FileHashes = @{}
        TrustedPaths = @()
        TrustAll = $false
        RemoveOnExit = $false
        IncludeVariants = $false
        EnvironmentName = $null
        Override = $false
        NoClobber = $false
        RevealValues = $false
    }
}

function Resolve-DotEnvValue {
<#
.SYNOPSIS
Resolves ${NAME} references inside a dotenv value.

.DESCRIPTION
Expands variable references in the form ${NAME} using a provided value map first,
then the current process environment. Missing variables are preserved unchanged.

.PARAMETER Value
The raw value to resolve.

.PARAMETER ValueMap
Hashtable of already-known dotenv values.

.PARAMETER MaxDepth
Maximum recursive expansion depth.

.EXAMPLE
Resolve-DotEnvValue -Value 'http://${HOST}:${PORT}' -ValueMap @{ HOST = 'localhost'; PORT = '8080' }

.INPUTS
System.String

.OUTPUTS
System.String

.NOTES
Windows PowerShell 5.1 compatible.
This function does not execute commands.
#>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]$Value,

        [Parameter(Mandatory = $false)]
        [hashtable]$ValueMap,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 50)]
        [int]$MaxDepth = 10
    )

    if ($null -eq $Value) {
        return ''
    }

    $resolved = [string]$Value
    $pattern = '\$\{([A-Za-z_][A-Za-z0-9_]*)\}'

    for ($depth = 0; $depth -lt $MaxDepth; $depth++) {
        $regexMatches = [regex]::Matches($resolved, $pattern)

        if ($regexMatches.Count -eq 0) {
            break
        }

        $builder = New-Object System.Text.StringBuilder
        $lastIndex = 0
        $changed = $false

        foreach ($match in $regexMatches) {
            [void]$builder.Append($resolved.Substring($lastIndex, $match.Index - $lastIndex))

            $name = $match.Groups[1].Value
            $replacement = $null
            $found = $false

            if ($null -ne $ValueMap -and $ValueMap.ContainsKey($name)) {
                $replacement = $ValueMap[$name]
                $found = $true
            }
            else {
                $envPath = "Env:\{0}" -f $name

                if (Test-Path -Path $envPath) {
                    $replacement = (Get-Item -Path $envPath).Value
                    $found = $true
                }
            }

            if ($found) {
                if ($null -eq $replacement) {
                    $replacement = ''
                }

                [void]$builder.Append([string]$replacement)
                $changed = $true
            }
            else {
                [void]$builder.Append($match.Value)
            }

            $lastIndex = $match.Index + $match.Length
        }

        if ($lastIndex -lt $resolved.Length) {
            [void]$builder.Append($resolved.Substring($lastIndex))
        }

        $newResolved = $builder.ToString()

        if (-not $changed -or $newResolved -eq $resolved) {
            $resolved = $newResolved
            break
        }

        $resolved = $newResolved
    }

    return $resolved
}

function Get-DotEnvFilePath {
<#
.SYNOPSIS
Resolves .env file paths in deterministic load order.

.DESCRIPTION
Returns existing .env files from either a direct .env file path or a directory path.
When -IncludeVariants is used, variant files are returned in precedence order:

.env
.env.local
.env.<EnvironmentName>
.env.<EnvironmentName>.local

Only existing files are returned.

.PARAMETER Path
A .env file path or directory path.

.PARAMETER IncludeVariants
Includes supported .env variant files.

.PARAMETER EnvironmentName
Optional environment name, such as development, test, staging, or production.

.EXAMPLE
Get-DotEnvFilePath -Path .\

.EXAMPLE
Get-DotEnvFilePath -Path .\ -IncludeVariants -EnvironmentName development

.INPUTS
System.String

.OUTPUTS
System.String

.NOTES
Windows PowerShell 5.1 compatible.
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeVariants,

        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName
    )

    begin {}

    process {
        try {
            $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

            if (Test-Path -LiteralPath $resolvedPath -PathType Leaf) {
                if ($PSCmdlet.ShouldProcess($resolvedPath, 'Return .env file path')) {
                    $resolvedPath
                }

                return
            }

            if (-not (Test-Path -LiteralPath $resolvedPath -PathType Container)) {
                Write-Error -Message ("Path not found: {0}" -f $Path) -Category ObjectNotFound
                return
            }

            $candidateNames = New-Object System.Collections.ArrayList
            [void]$candidateNames.Add('.env')

            if ($IncludeVariants) {
                [void]$candidateNames.Add('.env.local')

                if (-not [string]::IsNullOrWhiteSpace($EnvironmentName)) {
                    [void]$candidateNames.Add(('.env.{0}' -f $EnvironmentName))
                    [void]$candidateNames.Add(('.env.{0}.local' -f $EnvironmentName))
                }
            }

            foreach ($candidateName in $candidateNames) {
                $candidatePath = Join-Path $resolvedPath $candidateName

                if (Test-Path -LiteralPath $candidatePath -PathType Leaf) {
                    if ($PSCmdlet.ShouldProcess($candidatePath, 'Return .env file path')) {
                        $candidatePath
                    }
                }
            }
        }
        catch {
            Write-Error -Message ("Failed to resolve .env file path from '{0}'. {1}" -f $Path, $_.Exception.Message) -Category InvalidOperation
        }
    }

    end {}
}

function Test-DotEnvTrustedPath {
<#!
.SYNOPSIS
Tests whether a path is trusted for auto-loading.
.DESCRIPTION
Returns true when TrustAll is enabled or the target path is equal to or below a trusted path.
.PARAMETER Path
Path to test.
.PARAMETER TrustedPath
Trusted directory roots.
.PARAMETER TrustAll
Trust every path.
.EXAMPLE
Test-DotEnvTrustedPath -Path C:\Dev\App -TrustedPath C:\Dev
.INPUTS
None
.OUTPUTS
System.Boolean
.NOTES
Internal helper. Windows PowerShell 5.1 compatible.
#>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter()]
        [string[]]$TrustedPath,

        [Parameter()]
        [switch]$TrustAll
    )

    process {
        if ($TrustAll) {
            return $true
        }

        if ($null -eq $TrustedPath -or @($TrustedPath).Count -eq 0) {
            return $false
        }

        try {
            $resolvedPath = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')

            foreach ($trusted in $TrustedPath) {
                if ([string]::IsNullOrWhiteSpace($trusted)) {
                    continue
                }

                $resolvedTrusted = [System.IO.Path]::GetFullPath($trusted).TrimEnd('\')

                if ($resolvedPath.Equals($resolvedTrusted, [System.StringComparison]::OrdinalIgnoreCase)) {
                    return $true
                }

                $trustedWithSlash = $resolvedTrusted + '\'
                if ($resolvedPath.StartsWith($trustedWithSlash, [System.StringComparison]::OrdinalIgnoreCase)) {
                    return $true
                }
            }
        }
        catch {
            Write-Verbose ("Trusted path check failed. {0}" -f $_.Exception.Message)
        }

        return $false
    }
}

function ConvertFrom-DotEnv {
<#
.SYNOPSIS
Parses .env content into a PowerShell object.

.DESCRIPTION
Parses .env content from a file path or raw content string and returns a PSCustomObject
where each .env key becomes a property.

.PARAMETER Path
Path to a .env file.

.PARAMETER Content
Raw .env content.

.PARAMETER Strict
Reports invalid .env lines as errors instead of silently skipping them.

.EXAMPLE
ConvertFrom-DotEnv -Path .\.env

.EXAMPLE
ConvertFrom-DotEnv -Content "KEY=value"

.INPUTS
System.String

.OUTPUTS
System.Management.Automation.PSCustomObject

.NOTES
Windows PowerShell 5.1 compatible.
#>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'Content', ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [string]$Content,

        [Parameter(Mandatory = $false)]
        [switch]$Strict
    )

    begin {
        $contentBuffer = New-Object System.Collections.ArrayList
    }

    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'Content') {
                [void]$contentBuffer.Add($Content)
            }
        }
        catch {
            Write-Error -Message ("Failed to buffer .env content. {0}" -f $_.Exception.Message) -Category InvalidOperation
        }
    }

    end {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'Path') {
                if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
                    Write-Error -Message ("File not found: {0}" -f $Path) -Category ObjectNotFound
                    return
                }

                $rawContent = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
            }
            else {
                $rawContent = ($contentBuffer -join [Environment]::NewLine)
            }

            $result = @{}

            $lines = $rawContent -split "`r?`n"

            foreach ($line in $lines) {
                $trimmed = $line.Trim()

                if ([string]::IsNullOrWhiteSpace($trimmed)) {
                    continue
                }

                if ($trimmed.StartsWith('#')) {
                    continue
                }

                if ($trimmed -notmatch '=') {
                    if ($Strict) {
                        Write-Error -Message ("Invalid .env line. Missing '=' delimiter: {0}" -f $line) -Category InvalidData
                    }

                    continue
                }

                $pair = $trimmed -split '=', 2
                $name = $pair[0].Trim()

                if ([string]::IsNullOrWhiteSpace($name)) {
                    if ($Strict) {
                        Write-Error -Message ("Invalid .env line. Empty variable name: {0}" -f $line) -Category InvalidData
                    }

                    continue
                }

                $value = ''

                if ($pair.Count -ge 2) {
                    $value = $pair[1]
                }

                if ($null -eq $value) {
                    $value = ''
                }
                else {
                    $value = [string]$value
                }

                $value = $value.Trim()

                if ($value.Length -ge 2) {
                    if (
                        ($value.StartsWith('"') -and $value.EndsWith('"')) -or
                        ($value.StartsWith("'") -and $value.EndsWith("'"))
                    ) {
                        $value = $value.Substring(1, $value.Length - 2)
                    }
                }

                if ($null -eq $value) {
                    $value = ''
                }

                $result[$name] = [string]$value
            }

            [pscustomobject]$result
        }
        catch {
            Write-Error -Message ("Failed to parse .env content. {0}" -f $_.Exception.Message) -Category InvalidOperation
        }
    }
}

function Read-DotEnvFile {
<#
.SYNOPSIS
Reads a .env file and returns normalized key/value records.

.DESCRIPTION
Reads a single .env file, parses it with ConvertFrom-DotEnv, and returns one object
per environment variable with Name, Value, and SourcePath properties.

This function normalizes null values to empty strings so EMPTY_VALUE= remains an
empty environment variable rather than being treated as a missing value.

.PARAMETER Path
Path to a .env file.

.PARAMETER Strict
Reports invalid .env lines as errors.

.PARAMETER IncludeVariants
Compatibility parameter. Variant resolution should occur before calling this function.

.EXAMPLE
Read-DotEnvFile -Path .\.env

.EXAMPLE
Read-DotEnvFile -Path .\.env -Strict

.INPUTS
System.String

.OUTPUTS
System.Management.Automation.PSCustomObject

.NOTES
Windows PowerShell 5.1 compatible.
#>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [switch]$Strict
    )

    begin {}

    process {
        try {
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
                Write-Error -Message ("File not found: {0}" -f $Path) -Category ObjectNotFound
                return
            }

            $content = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
            $parsed = ConvertFrom-DotEnv -Content $content -Strict:$Strict

            foreach ($property in $parsed.PSObject.Properties) {
                $value = $property.Value

                if ($null -eq $value) {
                    $value = ''
                }
                else {
                    $value = [string]$value
                }

                [pscustomobject]@{
                    Name       = $property.Name
                    Value      = $value
                    SourcePath = $Path
                }
            }
        }
        catch {
            Write-Error -Message ("Failed to read .env file '{0}'. {1}" -f $Path, $_.Exception.Message) -Category ReadError
        }
    }

    end {}
}

function Import-DotEnvFile {
<#
.SYNOPSIS
Imports variables from one or more .env files into the current PowerShell process.

.DESCRIPTION
Reads .env-formatted files and loads variables into the current process environment
through the PowerShell Env: provider.

The function resolves dotenv files using Get-DotEnvFilePath, then reads each file
with Read-DotEnvFile.

By default, values are imported exactly as written. When -ExpandVariables is used,
references in the form ${NAME} are expanded using previously loaded dotenv values
first, then current process environment variables. Missing references are preserved
unchanged.

.PARAMETER Path
Path to a .env file or directory containing .env files.

.PARAMETER Scope
Environment scope. Currently only Process is supported.

.PARAMETER Override
Overwrite existing environment variables.

.PARAMETER NoClobber
Do not overwrite existing environment variables. This is the default behavior.

.PARAMETER IncludeVariants
Includes supported variant files such as .env.local and .env.<EnvironmentName>
when resolving files.

.PARAMETER EnvironmentName
Optional environment suffix used with variant files, such as development, test,
staging, production, or prod.

.PARAMETER Strict
Enables strict parsing behavior in the reader/parser.

.PARAMETER ExpandVariables
Expands ${NAME} references in values using already-loaded dotenv values first,
then current process environment variables. Missing references are preserved.

.PARAMETER PassThru
Returns import result records.

.PARAMETER RevealValues
Shows actual values in PassThru output. By default, non-empty values are masked.

.EXAMPLE
Import-DotEnvFile -Path .\.env -WhatIf

.EXAMPLE
Import-DotEnvFile -Path .\.env -Verbose -PassThru

.EXAMPLE
Import-DotEnvFile -Path . -IncludeVariants -EnvironmentName development -Override -Verbose

.EXAMPLE
Import-DotEnvFile -Path .\.env -ExpandVariables -Override -Verbose

.INPUTS
System.String

.OUTPUTS
System.Management.Automation.PSCustomObject

.NOTES
Windows PowerShell 5.1 compatible.
This command only writes to the current process environment.
Variable expansion is text-only and does not execute commands.
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Process')]
        [string]$Scope = 'Process',

        [Parameter(Mandatory = $false)]
        [switch]$Override,

        [Parameter(Mandatory = $false)]
        [switch]$NoClobber,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeVariants,

        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [switch]$Strict,

        [Parameter(Mandatory = $false)]
        [switch]$ExpandVariables,

        [Parameter(Mandatory = $false)]
        [switch]$PassThru,

        [Parameter(Mandatory = $false)]
        [switch]$RevealValues
    )

    begin {
        $valueMap = @{}
    }

    process {
        try {
            if ($Override -and $NoClobber) {
                Write-Error -Message 'Specify either -Override or -NoClobber, not both.' -Category InvalidArgument
                return
            }

            if (-not $Override -and -not $NoClobber) {
                $NoClobber = $true
            }

            $files = @(
                Get-DotEnvFilePath `
                    -Path $Path `
                    -IncludeVariants:$IncludeVariants `
                    -EnvironmentName $EnvironmentName
            )

            foreach ($file in $files) {
                foreach ($entry in Read-DotEnvFile -Path $file -Strict:$Strict) {
                    if ($null -eq $entry) {
                        continue
                    }

                    $name = $entry.Name
                    $value = $entry.Value

                    if ([string]::IsNullOrWhiteSpace($name)) {
                        Write-Error -Message ("Skipping .env entry with empty variable name from file: {0}" -f $file) -Category InvalidData
                        continue
                    }

                    if ($null -eq $value) {
                        $value = ''
                    }
                    else {
                        $value = [string]$value
                    }

                    if ($ExpandVariables) {
                        $value = Resolve-DotEnvValue -Value $value -ValueMap $valueMap
                    }

                    $envPath = "Env:\{0}" -f $name
                    $hadPreviousValue = Test-Path -Path $envPath
                    $previousValue = $null

                    if ($hadPreviousValue) {
                        $previousItem = Get-Item -Path $envPath -ErrorAction SilentlyContinue

                        if ($null -ne $previousItem) {
                            $previousValue = $previousItem.Value
                        }
                    }

                    $action = 'Set'
                    $changed = $false

                    if ($hadPreviousValue -and $NoClobber -and -not $Override) {
                        $action = 'SkippedExisting'
                    }
                    else {
                        if ($hadPreviousValue) {
                            $action = 'Updated'
                        }

                        if ($PSCmdlet.ShouldProcess(
                                ("{0}:{1}" -f $Scope, $name),
                                ("Set from {0}" -f (Split-Path -Path $file -Leaf))
                            )) {
                            Set-Item -Path $envPath -Value $value -ErrorAction Stop
                            $changed = $true

                            if (-not $script:DotEnvState.OriginalValues.ContainsKey($name)) {
                                $script:DotEnvState.OriginalValues[$name] = if ($hadPreviousValue) { $previousValue } else { $null }
                            }

                            $script:DotEnvState.LoadedVariables[$name] = @{
                                SourcePath       = $file
                                Scope            = $Scope
                                HadPreviousValue = $hadPreviousValue
                            }
                        }
                    }

                    # Keep the current resolved value available for later variables and later layers.
                    # This is intentional even when NoClobber skips an existing environment variable:
                    # the dotenv file's own value remains available for expansion in subsequent keys.
                    $valueMap[$name] = $value

                    if ($PassThru) {
                        $displayValue = $value

                        if (-not $RevealValues -and -not [string]::IsNullOrEmpty($value)) {
                            $displayValue = '********'
                        }

                        [pscustomobject]@{
                            Name             = $name
                            Value            = $displayValue
                            Scope            = $Scope
                            SourcePath       = $file
                            Action           = $action
                            Changed          = $changed
                            HadPreviousValue = $hadPreviousValue
                        }
                    }
                }
            }
        }
        catch {
            Write-Error -Message ("Failed to import .env file from path '{0}'. {1}" -f $Path, $_.Exception.Message) -Category InvalidOperation
        }
    }

    end {}
}

function Remove-DotEnvVariable {
<#
.SYNOPSIS
Removes environment variables defined in a .env file.

.DESCRIPTION
Reads one or more .env files, determines the variable names, and removes those
variables from the current process environment.

If the module recorded an original value for a variable, the original value is
restored instead of removing the variable.

.PARAMETER Path
Path to a .env file or directory.

.PARAMETER IncludeVariants
Includes supported .env variants when resolving files.

.PARAMETER EnvironmentName
Optional environment name used when resolving variant files.

.PARAMETER Strict
Enables strict parsing.

.PARAMETER PassThru
Returns result records.

.EXAMPLE
Remove-DotEnvVariable -Path .\.env -WhatIf

.EXAMPLE
Remove-DotEnvVariable -Path .\.env -Verbose -PassThru

.INPUTS
System.String

.OUTPUTS
System.Management.Automation.PSCustomObject

.NOTES
Windows PowerShell 5.1 compatible.
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeVariants,

        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [switch]$Strict,

        [Parameter(Mandatory = $false)]
        [switch]$PassThru
    )

    begin {}

    process {
        try {
            $files = @(
                Get-DotEnvFilePath `
                    -Path $Path `
                    -IncludeVariants:$IncludeVariants `
                    -EnvironmentName $EnvironmentName
            )

            foreach ($file in $files) {
                foreach ($entry in Read-DotEnvFile -Path $file -Strict:$Strict) {
                    if ($null -eq $entry) {
                        continue
                    }

                    $name = $entry.Name

                    if ([string]::IsNullOrWhiteSpace($name)) {
                        continue
                    }

                    $envPath = "Env:\{0}" -f $name
                    $existsBefore = Test-Path -Path $envPath
                    $action = 'Remove'
                    $changed = $false

                    $hasOriginalValue = $false
                    $originalValue = $null

                    if ($script:DotEnvState.OriginalValues.ContainsKey($name)) {
                        $hasOriginalValue = $true
                        $originalValue = $script:DotEnvState.OriginalValues[$name]
                    }

                    if ($PSCmdlet.ShouldProcess(("Process:{0}" -f $name), $action)) {
                        if ($hasOriginalValue -and $null -ne $originalValue) {
                            Set-Item -Path $envPath -Value ([string]$originalValue) -ErrorAction Stop
                            $action = 'Restored'
                            $changed = $true
                        }
                        else {
                            if (Test-Path -Path $envPath) {
                                Remove-Item -Path $envPath -ErrorAction Stop
                                $changed = $true
                            }
                        }

                        if ($script:DotEnvState.LoadedVariables.ContainsKey($name)) {
                            $script:DotEnvState.LoadedVariables.Remove($name)
                        }

                        if ($script:DotEnvState.OriginalValues.ContainsKey($name)) {
                            $script:DotEnvState.OriginalValues.Remove($name)
                        }
                    }

                    if ($PassThru) {
                        [pscustomobject]@{
                            Name         = $name
                            Scope        = 'Process'
                            SourcePath   = $file
                            Action       = $action
                            Changed      = $changed
                            ExistedBefore = $existsBefore
                        }
                    }
                }
            }
        }
        catch {
            Write-Error -Message ("Failed to remove .env variables from path '{0}'. {1}" -f $Path, $_.Exception.Message) -Category InvalidOperation
        }
    }

    end {}
}

function Test-DotEnvFile {
<#!
.SYNOPSIS
Validates .env file syntax and optional .env.example coverage.
.DESCRIPTION
Parses a .env file in strict mode and optionally verifies that keys from an example file exist.
.PARAMETER Path
Path to .env file.
.PARAMETER ExamplePath
Optional .env.example path.
.EXAMPLE
Test-DotEnvFile -Path .\.env -WhatIf
.EXAMPLE
Test-DotEnvFile -Path .\.env -ExamplePath .\.env.example
.INPUTS
System.String
.OUTPUTS
System.Management.Automation.PSCustomObject
.NOTES
Windows PowerShell 5.1 compatible.
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [string]$ExamplePath
    )

    process {
        $errors = New-Object System.Collections.ArrayList
        $warnings = New-Object System.Collections.ArrayList
        $keys = @()

        try {
            if ($PSCmdlet.ShouldProcess($Path, 'Validate .env file')) {
                $records = @(Read-DotEnvFile -Path $Path -Strict)
                $keys = @($records | Select-Object -ExpandProperty Name -Unique)

                if ($ExamplePath) {
                    $exampleRecords = @(Read-DotEnvFile -Path $ExamplePath -Strict)
                    foreach ($exampleName in @($exampleRecords | Select-Object -ExpandProperty Name -Unique)) {
                        if ($keys -notcontains $exampleName) {
                            [void]$warnings.Add("Missing key from example: $exampleName")
                        }
                    }
                }
            }
        }
        catch {
            [void]$errors.Add($_.Exception.Message)
        }

        [pscustomobject]@{
            Path = $Path
            IsValid = (@($errors).Count -eq 0)
            KeyCount = @($keys).Count
            Keys = $keys
            ErrorCount = @($errors).Count
            WarningCount = @($warnings).Count
            Errors = @($errors)
            Warnings = @($warnings)
        }
    }
}

function Export-DotEnvFile {
<#!
.SYNOPSIS
Exports selected process environment variables to a .env file.
.DESCRIPTION
Writes environment variables to .env format.
.PARAMETER Path
Destination .env path.
.PARAMETER Name
Optional variable names. If omitted, all process environment variables are exported.
.PARAMETER Force
Overwrite an existing file.
.EXAMPLE
Export-DotEnvFile -Path .\.env.export -Name API_URL,DB_NAME -WhatIf
.EXAMPLE
Export-DotEnvFile -Path .\.env.export -Force
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
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [string[]]$Name,

        [Parameter()]
        [switch]$Force
    )

    process {
        try {
            $targetPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

            if ((Test-Path -LiteralPath $targetPath) -and -not $Force) {
                Write-Error -Message ("File already exists: {0}. Use -Force to overwrite." -f $targetPath) -Category ResourceExists
                return
            }

            $items = Get-ChildItem Env:
            if ($Name -and @($Name).Count -gt 0) {
                $items = foreach ($n in $Name) {
                    Get-Item -Path ('Env:\{0}' -f $n) -ErrorAction SilentlyContinue
                }
            }

            $lines = foreach ($item in $items) {
                if ($null -ne $item) {
                    $escaped = [string]$item.Value
                    if ($escaped -match '\s|#|=') {
                        $escaped = '"' + ($escaped -replace '"', '\"') + '"'
                    }
                    '{0}={1}' -f $item.Name, $escaped
                }
            }

            if ($PSCmdlet.ShouldProcess($targetPath, 'Export .env file')) {
                $parent = Split-Path -Parent $targetPath
                if ($parent -and -not (Test-Path -LiteralPath $parent)) {
                    New-Item -Path $parent -ItemType Directory -Force | Out-Null
                }

                Set-Content -LiteralPath $targetPath -Value $lines -Encoding UTF8
                Get-Item -LiteralPath $targetPath
            }
        }
        catch {
            Write-Error -Message ("Failed to export .env file. {0}" -f $_.Exception.Message) -Category WriteError
        }
    }
}

function Get-DotEnvAutoLoadState {
<#!
.SYNOPSIS
Gets DotEnvTools auto-load state.
.DESCRIPTION
Returns current auto-load settings and tracked file information.
.EXAMPLE
Get-DotEnvAutoLoadState
.EXAMPLE
Get-DotEnvAutoLoadState -WhatIf
.INPUTS
None
.OUTPUTS
System.Management.Automation.PSCustomObject
.NOTES
Windows PowerShell 5.1 compatible.
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param()

    process {
        if ($PSCmdlet.ShouldProcess('DotEnvTools state', 'Return auto-load state')) {
            [pscustomobject]@{
                AutoLoadEnabled = [bool]$script:DotEnvState.AutoLoadEnabled
                LastPath = $script:DotEnvState.LastPath
                TrustedPath = @($script:DotEnvState.TrustedPaths)
                TrustAll = [bool]$script:DotEnvState.TrustAll
                RemoveOnExit = [bool]$script:DotEnvState.RemoveOnExit
                NoClobber = [bool]$script:DotEnvState.NoClobber
                IncludeVariants = [bool]$script:DotEnvState.IncludeVariants
                EnvironmentName = $script:DotEnvState.EnvironmentName
                LastLoadedFiles = @($script:DotEnvState.LastLoadedFiles)
                TrackedFileCount = @($script:DotEnvState.FileHashes.Keys).Count
            }
        }
    }
}

function Invoke-DotEnvAutoLoadNow {
<#!
.SYNOPSIS
Runs the DotEnvTools auto-load check for the current directory immediately.
.DESCRIPTION
Loads .env files for the current directory when auto-load is enabled and the directory is trusted.
.PARAMETER PassThru
Returns auto-load state after execution.
.EXAMPLE
Invoke-DotEnvAutoLoadNow -WhatIf
.EXAMPLE
Invoke-DotEnvAutoLoadNow -Verbose -PassThru
.INPUTS
None
.OUTPUTS
System.Management.Automation.PSCustomObject
.NOTES
Reloads unchanged files when tracked variables are missing.
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [switch]$PassThru
    )

    process {
        if (-not $script:DotEnvState.AutoLoadEnabled) {
            Write-Verbose 'DotEnvTools auto-load is not enabled.'
            if ($PassThru) { Get-DotEnvAutoLoadState }
            return
        }

        try {
            $currentPath = (Get-Location).Path

            if (-not (Test-DotEnvTrustedPath -Path $currentPath -TrustedPath $script:DotEnvState.TrustedPaths -TrustAll:$script:DotEnvState.TrustAll)) {
                Write-Verbose ("Current path is not trusted for .env auto-load: {0}" -f $currentPath)
                if ($PassThru) { Get-DotEnvAutoLoadState }
                return
            }

            if ($script:DotEnvState.RemoveOnExit -and $script:DotEnvState.LastPath -and ($script:DotEnvState.LastPath -ne $currentPath)) {
                foreach ($oldFile in @($script:DotEnvState.LastLoadedFiles)) {
                    if (Test-Path -LiteralPath $oldFile) {
                        Remove-DotEnvVariable -Path $oldFile -ErrorAction SilentlyContinue | Out-Null
                    }
                }
            }

            $files = @(Get-DotEnvFilePath -Path $currentPath -IncludeVariants:$script:DotEnvState.IncludeVariants -EnvironmentName $script:DotEnvState.EnvironmentName)
            $script:DotEnvState.LastLoadedFiles = $files

            foreach ($file in $files) {
                $hash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash
                $oldHash = $null

                if ($script:DotEnvState.FileHashes.ContainsKey($file)) {
                    $oldHash = $script:DotEnvState.FileHashes[$file]
                }

                $shouldLoad = $true
                if ($oldHash -eq $hash) {
                    $trackedVariables = @()
                    if ($script:DotEnvState.LoadedFiles.ContainsKey($file)) {
                        $trackedVariables = @($script:DotEnvState.LoadedFiles[$file])
                    }

                    if (@($trackedVariables).Count -gt 0) {
                        $allStillPresent = $true
                        foreach ($name in $trackedVariables) {
                            if (-not (Test-Path -Path ('Env:\{0}' -f $name))) {
                                $allStillPresent = $false
                                break
                            }
                        }

                        if ($allStillPresent) {
                            $shouldLoad = $false
                            Write-Verbose ("Skipping unchanged .env file because tracked variables are still present: {0}" -f $file)
                        }
                        else {
                            Write-Verbose ("Reloading unchanged .env file because one or more tracked variables are missing: {0}" -f $file)
                        }
                    }
                    else {
                        Write-Verbose ("Reloading unchanged .env file because no tracked variable list exists: {0}" -f $file)
                    }
                }

                if (-not $shouldLoad) {
                    continue
                }

                if ($PSCmdlet.ShouldProcess($file, 'Auto-load .env file')) {
                    if ($script:DotEnvState.NoClobber) {
                        $records = @(Import-DotEnvFile -Path $file -NoClobber -PassThru -RevealValues -ErrorAction Stop)
                    }
                    else {
                        $records = @(Import-DotEnvFile -Path $file -Override -PassThru -RevealValues -ErrorAction Stop)
                    }

                    $loadedNames = @(
                        $records |
                            Where-Object { $_.Changed -eq $true -or $_.Action -eq 'Set' -or $_.Action -eq 'Updated' -or $_.Action -eq 'SkippedExisting' } |
                            Select-Object -ExpandProperty Name -Unique
                    )

                    $script:DotEnvState.FileHashes[$file] = $hash
                    $script:DotEnvState.LoadedFiles[$file] = $loadedNames
                }
            }

            $script:DotEnvState.LastPath = $currentPath
        }
        catch {
            Write-Error -Message ("DotEnvTools immediate auto-load failed. {0}" -f $_.Exception.Message) -Category InvalidOperation
        }

        if ($PassThru) { Get-DotEnvAutoLoadState }
    }
}

function Enable-DotEnvAutoLoad {
<#!
.SYNOPSIS
Enables automatic .env loading for trusted directories.
.DESCRIPTION
Overrides the prompt function to check for .env files when the prompt renders.
.PARAMETER TrustedPath
Trusted paths allowed to auto-load .env files.
.PARAMETER TrustAll
Trust all paths.
.PARAMETER RemoveOnExit
Remove/restore variables when leaving a directory.
.PARAMETER IncludeVariants
Include .env variants.
.PARAMETER EnvironmentName
Optional environment name.
.PARAMETER Override
Overwrite existing variables.
.PARAMETER NoClobber
Do not overwrite existing variables.
.EXAMPLE
Enable-DotEnvAutoLoad -TrustedPath C:\Dev -WhatIf
.EXAMPLE
Enable-DotEnvAutoLoad -TrustedPath C:\Dev -RemoveOnExit -Verbose
.INPUTS
None
.OUTPUTS
System.Management.Automation.PSCustomObject
.NOTES
Auto-load is opt-in. Windows PowerShell 5.1 compatible.
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [string[]]$TrustedPath,

        [Parameter()]
        [switch]$TrustAll,

        [Parameter()]
        [switch]$RemoveOnExit,

        [Parameter()]
        [switch]$IncludeVariants,

        [Parameter()]
        [string]$EnvironmentName,

        [Parameter()]
        [switch]$Override,

        [Parameter()]
        [switch]$NoClobber
    )

    process {
        if ($PSCmdlet.ShouldProcess('PowerShell prompt', 'Enable .env auto-load')) {
            $originalPromptVariable = Get-Variable -Name OriginalPrompt -Scope Script -ErrorAction SilentlyContinue
            if ($null -eq $originalPromptVariable) {
                $promptCommand = Get-Command prompt -ErrorAction SilentlyContinue
                if ($promptCommand -and ($promptCommand.PSObject.Properties.Name -contains 'ScriptBlock') -and $promptCommand.ScriptBlock) {
                    $script:OriginalPrompt = $promptCommand.ScriptBlock
                }
                else {
                    $script:OriginalPrompt = { "PS $($executionContext.SessionState.Path.CurrentLocation)> " }
                }
            }

            if ($TrustedPath -and @($TrustedPath).Count -gt 0) {
                $script:DotEnvState.TrustedPaths = @($TrustedPath | ForEach-Object { [System.IO.Path]::GetFullPath($_).TrimEnd('\') })
            }
            elseif (-not $TrustAll -and @($script:DotEnvState.TrustedPaths).Count -eq 0) {
                $script:DotEnvState.TrustedPaths = @((Get-Location).Path)
            }

            $script:DotEnvState.AutoLoadEnabled = $true
            $script:DotEnvState.TrustAll = [bool]$TrustAll
            $script:DotEnvState.RemoveOnExit = [bool]$RemoveOnExit
            $script:DotEnvState.IncludeVariants = [bool]$IncludeVariants
            $script:DotEnvState.EnvironmentName = $EnvironmentName
            $script:DotEnvState.Override = [bool]$Override
            $script:DotEnvState.NoClobber = -not [bool]$Override
            if ($NoClobber) { $script:DotEnvState.NoClobber = $true }

            $dotEnvPromptScriptBlock = {
                try {
                    Invoke-DotEnvAutoLoadNow -ErrorAction SilentlyContinue | Out-Null
                }
                catch {
                    Write-Verbose ("DotEnvTools prompt auto-load failed. {0}" -f $_.Exception.Message)
                }

                if ($script:OriginalPrompt) {
                    & $script:OriginalPrompt
                }
                else {
                    "PS $($executionContext.SessionState.Path.CurrentLocation)> "
                }
            }

            Set-Item -Path Function:\global:prompt -Value $dotEnvPromptScriptBlock -Force

            [pscustomobject]@{
                Enabled = $true
                TrustedPath = @($script:DotEnvState.TrustedPaths)
                TrustAll = [bool]$script:DotEnvState.TrustAll
                RemoveOnExit = [bool]$script:DotEnvState.RemoveOnExit
                IncludeVariants = [bool]$script:DotEnvState.IncludeVariants
                EnvironmentName = $script:DotEnvState.EnvironmentName
            }
        }
    }
}

function Disable-DotEnvAutoLoad {
<#!
.SYNOPSIS
Disables DotEnvTools automatic .env loading.
.DESCRIPTION
Restores the original prompt function when known and disables auto-load state.
.PARAMETER RemoveCurrent
Removes variables from the last loaded files.
.EXAMPLE
Disable-DotEnvAutoLoad -WhatIf
.EXAMPLE
Disable-DotEnvAutoLoad -RemoveCurrent -Verbose
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
        [Parameter()]
        [switch]$RemoveCurrent
    )

    process {
        if ($PSCmdlet.ShouldProcess('PowerShell prompt', 'Disable .env auto-load')) {
            if ($RemoveCurrent) {
                foreach ($file in @($script:DotEnvState.LastLoadedFiles)) {
                    if (Test-Path -LiteralPath $file) {
                        Remove-DotEnvVariable -Path $file -ErrorAction SilentlyContinue | Out-Null
                    }
                }
            }

            $script:DotEnvState.AutoLoadEnabled = $false

            $originalPromptVariable = Get-Variable -Name OriginalPrompt -Scope Script -ErrorAction SilentlyContinue
            if ($null -ne $originalPromptVariable -and $script:OriginalPrompt) {
                Set-Item -Path Function:\global:prompt -Value $script:OriginalPrompt -ErrorAction SilentlyContinue
            }

            [pscustomobject]@{
                Enabled = $false
                RemovedCurrent = [bool]$RemoveCurrent
            }
        }
    }
}

function Add-DotEnvAutoLoadProfile {
<#!
.SYNOPSIS
Adds DotEnvTools auto-load initialization to the current user's profile.
.DESCRIPTION
Appends import and Enable-DotEnvAutoLoad lines to the current user's PowerShell profile.
.PARAMETER TrustedPath
Trusted paths for auto-load.
.PARAMETER TrustAll
Trust all paths.
.EXAMPLE
Add-DotEnvAutoLoadProfile -TrustedPath C:\Dev -WhatIf
.EXAMPLE
Add-DotEnvAutoLoadProfile -TrustedPath C:\Dev -Verbose
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
        [Parameter()]
        [string[]]$TrustedPath,

        [Parameter()]
        [switch]$TrustAll
    )

    process {
        $profilePath = $PROFILE.CurrentUserCurrentHost
        $lines = New-Object System.Collections.ArrayList
        [void]$lines.Add('# DotEnvTools auto-load')
        [void]$lines.Add('Import-Module DotEnvTools -ErrorAction SilentlyContinue')

        if ($TrustAll) {
            [void]$lines.Add('Enable-DotEnvAutoLoad -TrustAll | Out-Null')
        }
        elseif ($TrustedPath -and @($TrustedPath).Count -gt 0) {
            $quoted = @($TrustedPath | ForEach-Object { "'{0}'" -f ($_ -replace "'", "''") }) -join ', '
            [void]$lines.Add(('Enable-DotEnvAutoLoad -TrustedPath @({0}) | Out-Null' -f $quoted))
        }
        else {
            [void]$lines.Add('Enable-DotEnvAutoLoad | Out-Null')
        }

        if ($PSCmdlet.ShouldProcess($profilePath, 'Add DotEnvTools auto-load profile block')) {
            $parent = Split-Path -Parent $profilePath
            if (-not (Test-Path -LiteralPath $parent)) {
                New-Item -Path $parent -ItemType Directory -Force | Out-Null
            }

            Add-Content -LiteralPath $profilePath -Value '' -Encoding UTF8
            Add-Content -LiteralPath $profilePath -Value $lines -Encoding UTF8
            Get-Item -LiteralPath $profilePath
        }
    }
}

function Remove-DotEnvAutoLoadProfile {
<#!
.SYNOPSIS
Removes DotEnvTools auto-load lines from the current user's profile.
.DESCRIPTION
Removes lines containing DotEnvTools auto-load profile markers.
.EXAMPLE
Remove-DotEnvAutoLoadProfile -WhatIf
.EXAMPLE
Remove-DotEnvAutoLoadProfile -Verbose
.INPUTS
None
.OUTPUTS
System.IO.FileInfo
.NOTES
Windows PowerShell 5.1 compatible.
#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.IO.FileInfo])]
    param()

    process {
        $profilePath = $PROFILE.CurrentUserCurrentHost
        if (-not (Test-Path -LiteralPath $profilePath)) {
            Write-Error -Message ("Profile not found: {0}" -f $profilePath) -Category ObjectNotFound
            return
        }

        if ($PSCmdlet.ShouldProcess($profilePath, 'Remove DotEnvTools auto-load profile lines')) {
            $content = Get-Content -LiteralPath $profilePath -ErrorAction Stop
            $filtered = $content | Where-Object {
                ($_ -notmatch 'DotEnvTools auto-load') -and
                ($_ -notmatch 'Import-Module DotEnvTools') -and
                ($_ -notmatch 'Enable-DotEnvAutoLoad')
            }
            Set-Content -LiteralPath $profilePath -Value $filtered -Encoding UTF8
            Get-Item -LiteralPath $profilePath
        }
    }
}