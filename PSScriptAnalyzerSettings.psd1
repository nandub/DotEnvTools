@{
    Rules = @{
        PSUseCompatibleSyntax = @{
            Enable = $true
            TargetVersions = @('5.1')
        }
        PSAvoidGlobalFunctions = @{
            Enable = $true
            IgnoreFunctionName = @(
                'prompt'
            )
        }
    }
}
