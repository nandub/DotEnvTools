@{
    RootModule = 'DotEnvTools.psm1'
    ModuleVersion = '0.7.1'
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
        'Get-DotEnvAutoLoadState',
        'Get-DotEnvFilePath',
        'Import-DotEnvFile',
        'Invoke-DotEnvAutoLoadNow',
        'Read-DotEnvFile',
        'Remove-DotEnvAutoLoadProfile',
        'Remove-DotEnvVariable',
        'Test-DotEnvFile'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('dotenv', 'env', 'PowerShell', 'WindowsPowerShell')
            LicenseUri = ''
            ProjectUri = ''
            ReleaseNotes = '0.7.1 hardens no-clobber cleanup, strict validation reporting, quoted export round-trips, and documentation.'
        }
    }
}












