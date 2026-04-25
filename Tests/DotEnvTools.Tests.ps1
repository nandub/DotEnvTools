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