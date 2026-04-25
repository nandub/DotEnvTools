<#
.SYNOPSIS
Pester tests for DotEnvTools.

.DESCRIPTION
Validates parsing, import/remove behavior, and the auto-load regression where
an unchanged .env file must reload when tracked variables are missing.

.NOTES
Requires Pester 5.x.
Windows PowerShell 5.1 compatible.
#>

BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\Source\DotEnvTools.psd1'

    Remove-Module DotEnvTools -Force -ErrorAction SilentlyContinue
    Import-Module $modulePath -Force -ErrorAction Stop
}

Describe 'DotEnvTools basic behavior' {

    BeforeEach {
        $script:TestRoot = Join-Path $TestDrive 'DotEnvToolsCase'
        New-Item -Path $script:TestRoot -ItemType Directory -Force | Out-Null

        $script:EnvPath = Join-Path $script:TestRoot '.env'

@'
API_URL=https://localhost:8443
DB_NAME=DotEnvDemo
QUOTED_VALUE="hello world"
EMPTY_VALUE=
'@ | Set-Content -Path $script:EnvPath -Encoding UTF8

        Remove-Item Env:\API_URL -ErrorAction SilentlyContinue
        Remove-Item Env:\DB_NAME -ErrorAction SilentlyContinue
        Remove-Item Env:\QUOTED_VALUE -ErrorAction SilentlyContinue
        Remove-Item Env:\EMPTY_VALUE -ErrorAction SilentlyContinue
    }

    AfterEach {
        Disable-DotEnvAutoLoad -ErrorAction SilentlyContinue | Out-Null

        if (Test-Path -Path $script:EnvPath) {
            Remove-DotEnvVariable -Path $script:EnvPath -ErrorAction SilentlyContinue | Out-Null
        }

        Remove-Item Env:\API_URL -ErrorAction SilentlyContinue
        Remove-Item Env:\DB_NAME -ErrorAction SilentlyContinue
        Remove-Item Env:\QUOTED_VALUE -ErrorAction SilentlyContinue
        Remove-Item Env:\EMPTY_VALUE -ErrorAction SilentlyContinue
    }

    It 'Parses simple dotenv content' {
        $content = @'
API_URL=https://localhost:8443
DB_NAME=DotEnvDemo
QUOTED_VALUE="hello world"
EMPTY_VALUE=
'@

        $result = ConvertFrom-DotEnv -Content $content

        $result.API_URL | Should -Be 'https://localhost:8443'
        $result.DB_NAME | Should -Be 'DotEnvDemo'
        $result.QUOTED_VALUE | Should -Be 'hello world'
        $result.EMPTY_VALUE | Should -Be ''
    }

    It 'Unescapes quotes inside double quoted values' {
        $content = 'QUOTED_VALUE="hello \"world\" there"'

        $result = ConvertFrom-DotEnv -Content $content

        $result.QUOTED_VALUE | Should -Be 'hello "world" there'
    }

    It 'Reads EMPTY_VALUE as an empty string record' {
        $record = Read-DotEnvFile -Path $script:EnvPath |
            Where-Object { $_.Name -eq 'EMPTY_VALUE' }

        $record | Should -Not -BeNullOrEmpty
        $record.Value | Should -Be ''
    }

    It 'Imports and removes environment variables' {
        Import-DotEnvFile -Path $script:EnvPath -Override | Out-Null

        $env:API_URL | Should -Be 'https://localhost:8443'
        $env:DB_NAME | Should -Be 'DotEnvDemo'
        $env:QUOTED_VALUE | Should -Be 'hello world'

        Remove-DotEnvVariable -Path $script:EnvPath | Out-Null

        Test-Path Env:\API_URL | Should -BeFalse
        Test-Path Env:\DB_NAME | Should -BeFalse
        Test-Path Env:\QUOTED_VALUE | Should -BeFalse
        Test-Path Env:\EMPTY_VALUE | Should -BeFalse
    }

    It 'Does not remove existing variables skipped by NoClobber' {
        $env:API_URL = 'pre-existing'

        Import-DotEnvFile -Path $script:EnvPath | Out-Null

        $env:API_URL | Should -Be 'pre-existing'

        Remove-DotEnvVariable -Path $script:EnvPath | Out-Null

        $env:API_URL | Should -Be 'pre-existing'
    }

    It 'Reports malformed dotenv files as invalid' {
        Set-Content -Path $script:EnvPath -Value @(
            'API_URL=https://localhost:8443'
            'BADLINE'
        ) -Encoding UTF8

        $result = Test-DotEnvFile -Path $script:EnvPath

        $result.IsValid | Should -BeFalse
        $result.ErrorCount | Should -BeGreaterThan 0
        ($result.Errors -join "`n") | Should -Match "Missing '=' delimiter"
    }

    It 'Round-trips exported values with embedded quotes' {
        $exportPath = Join-Path $script:TestRoot '.env.export'
        $env:QUOTED_VALUE = 'hello "world" there'

        Export-DotEnvFile -Path $exportPath -Name QUOTED_VALUE -Force | Out-Null

        $result = ConvertFrom-DotEnv -Path $exportPath

        $result.QUOTED_VALUE | Should -Be 'hello "world" there'
    }

    It 'Reloads unchanged dotenv file when tracked variables are missing' {
        Push-Location $script:TestRoot

        try {
            Enable-DotEnvAutoLoad -TrustedPath $script:TestRoot | Out-Null

            Invoke-DotEnvAutoLoadNow | Out-Null

            $env:API_URL | Should -Be 'https://localhost:8443'

            Remove-DotEnvVariable -Path $script:EnvPath | Out-Null

            Test-Path Env:\API_URL | Should -BeFalse

            Invoke-DotEnvAutoLoadNow | Out-Null

            $env:API_URL | Should -Be 'https://localhost:8443'
            $env:DB_NAME | Should -Be 'DotEnvDemo'
            $env:QUOTED_VALUE | Should -Be 'hello world'
        }
        finally {
            Pop-Location
        }
    }
}

Describe 'DotEnvTools layered dotenv loading' {

    BeforeEach {
        $script:LayerRoot = Join-Path $TestDrive 'DotEnvToolsLayerCase'
        New-Item -Path $script:LayerRoot -ItemType Directory -Force | Out-Null

@'
BASE_ONLY=base
SHARED_VALUE=base
'@ | Set-Content -Path (Join-Path $script:LayerRoot '.env') -Encoding UTF8

@'
LOCAL_ONLY=local
SHARED_VALUE=local
'@ | Set-Content -Path (Join-Path $script:LayerRoot '.env.local') -Encoding UTF8

@'
DEV_ONLY=development
SHARED_VALUE=development
'@ | Set-Content -Path (Join-Path $script:LayerRoot '.env.development') -Encoding UTF8

@'
DEV_LOCAL_ONLY=development-local
SHARED_VALUE=development-local
'@ | Set-Content -Path (Join-Path $script:LayerRoot '.env.development.local') -Encoding UTF8

        Remove-Item Env:\BASE_ONLY -ErrorAction SilentlyContinue
        Remove-Item Env:\LOCAL_ONLY -ErrorAction SilentlyContinue
        Remove-Item Env:\DEV_ONLY -ErrorAction SilentlyContinue
        Remove-Item Env:\DEV_LOCAL_ONLY -ErrorAction SilentlyContinue
        Remove-Item Env:\SHARED_VALUE -ErrorAction SilentlyContinue
    }

    AfterEach {
        Disable-DotEnvAutoLoad -ErrorAction SilentlyContinue | Out-Null

        Remove-Item Env:\BASE_ONLY -ErrorAction SilentlyContinue
        Remove-Item Env:\LOCAL_ONLY -ErrorAction SilentlyContinue
        Remove-Item Env:\DEV_ONLY -ErrorAction SilentlyContinue
        Remove-Item Env:\DEV_LOCAL_ONLY -ErrorAction SilentlyContinue
        Remove-Item Env:\SHARED_VALUE -ErrorAction SilentlyContinue
    }

    It 'Resolves layered dotenv files in deterministic order' {
        $files = @(
            Get-DotEnvFilePath -Path $script:LayerRoot -IncludeVariants -EnvironmentName development
        )

        @($files).Count | Should -Be 4
        [System.IO.Path]::GetFileName($files[0]) | Should -Be '.env'
        [System.IO.Path]::GetFileName($files[1]) | Should -Be '.env.local'
        [System.IO.Path]::GetFileName($files[2]) | Should -Be '.env.development'
        [System.IO.Path]::GetFileName($files[3]) | Should -Be '.env.development.local'
    }

    It 'Loads only .env when variants are not included' {
        Import-DotEnvFile -Path $script:LayerRoot -Override | Out-Null

        $env:BASE_ONLY | Should -Be 'base'
        $env:LOCAL_ONLY | Should -BeNullOrEmpty
        $env:DEV_ONLY | Should -BeNullOrEmpty
        $env:DEV_LOCAL_ONLY | Should -BeNullOrEmpty
        $env:SHARED_VALUE | Should -Be 'base'
    }

    It 'Loads layered dotenv files with override precedence' {
        Import-DotEnvFile -Path $script:LayerRoot -IncludeVariants -EnvironmentName development -Override | Out-Null

        $env:BASE_ONLY | Should -Be 'base'
        $env:LOCAL_ONLY | Should -Be 'local'
        $env:DEV_ONLY | Should -Be 'development'
        $env:DEV_LOCAL_ONLY | Should -Be 'development-local'
        $env:SHARED_VALUE | Should -Be 'development-local'
    }

    It 'Preserves first value when NoClobber is active' {
        Import-DotEnvFile -Path $script:LayerRoot -IncludeVariants -EnvironmentName development -NoClobber | Out-Null

        $env:BASE_ONLY | Should -Be 'base'
        $env:LOCAL_ONLY | Should -Be 'local'
        $env:DEV_ONLY | Should -Be 'development'
        $env:DEV_LOCAL_ONLY | Should -Be 'development-local'
        $env:SHARED_VALUE | Should -Be 'base'
    }
}

Describe 'DotEnvTools variable expansion' {

    BeforeEach {
        $script:ExpandRoot = Join-Path $TestDrive 'DotEnvToolsExpandCase'
        New-Item -Path $script:ExpandRoot -ItemType Directory -Force | Out-Null

@'
HOST=localhost
PORT=8080
API_URL=http://${HOST}:${PORT}
LITERAL_VALUE=${MISSING_VALUE}
'@ | Set-Content -Path (Join-Path $script:ExpandRoot '.env') -Encoding UTF8

        Remove-Item Env:\HOST -ErrorAction SilentlyContinue
        Remove-Item Env:\PORT -ErrorAction SilentlyContinue
        Remove-Item Env:\API_URL -ErrorAction SilentlyContinue
        Remove-Item Env:\LITERAL_VALUE -ErrorAction SilentlyContinue
        Remove-Item Env:\MISSING_VALUE -ErrorAction SilentlyContinue
    }

    AfterEach {
        Remove-Item Env:\HOST -ErrorAction SilentlyContinue
        Remove-Item Env:\PORT -ErrorAction SilentlyContinue
        Remove-Item Env:\API_URL -ErrorAction SilentlyContinue
        Remove-Item Env:\LITERAL_VALUE -ErrorAction SilentlyContinue
        Remove-Item Env:\MISSING_VALUE -ErrorAction SilentlyContinue
    }

    It 'Does not expand variables by default' {
        Import-DotEnvFile -Path $script:ExpandRoot -Override | Out-Null

        $env:API_URL | Should -Be 'http://${HOST}:${PORT}'
    }

    It 'Expands variables when ExpandVariables is used' {
        Import-DotEnvFile -Path $script:ExpandRoot -Override -ExpandVariables | Out-Null

        $env:API_URL | Should -Be 'http://localhost:8080'
    }

    It 'Preserves missing variable references' {
        Import-DotEnvFile -Path $script:ExpandRoot -Override -ExpandVariables | Out-Null

        $env:LITERAL_VALUE | Should -Be '${MISSING_VALUE}'
    }
}
