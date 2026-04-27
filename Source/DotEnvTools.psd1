@{
    RootModule = 'DotEnvTools.psm1'
    ModuleVersion = '0.8.9'
    GUID = '4d69b4ea-9d83-4e24-8d6f-6b74c3a6d052'
    Author = 'DotEnvTools Contributors'
    CompanyName = 'Community'
    Copyright = '(c) DotEnvTools Contributors. All rights reserved.'
    Description = 'Windows PowerShell 5.1 compatible .env file loader with opt-in auto-load support.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Add-DotEnvAutoLoadProfile',
        'ConvertFrom-DotEnv',
        'Disable-DotEnvAutoLoad',
        'Enable-DotEnvAutoLoad',
        'Export-DotEnvFile',
        'Find-DotEnvFile',
        'Get-DotEnvAutoLoadState',
        'Get-DotEnvFilePath',
        'Get-DotEnvValue',
        'Import-DotEnvFile',
        'Invoke-DotEnvCommand',
        'Invoke-DotEnvAutoLoadNow',
        'New-DotEnvFile',
        'Read-DotEnvMap',
        'Read-DotEnvFile',
        'Remove-DotEnvAutoLoadProfile',
        'Remove-DotEnvValue',
        'Remove-DotEnvVariable',
        'Set-DotEnvValue',
        'Test-DotEnvGitIgnore',
        'Test-DotEnvFile'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('dotenv', 'env', 'PowerShell', 'WindowsPowerShell')
            LicenseUri = 'https://github.com/nandub/DotEnvTools/blob/main/LICENSE'
            ProjectUri = 'https://github.com/nandub/DotEnvTools'
            ReleaseNotes = '0.8.9 expands GitHub CI coverage across Ubuntu, Windows, and macOS.'
        }
    }
}












