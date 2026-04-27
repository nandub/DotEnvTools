---
external help file: DotEnvTools-help.xml
Module Name: DotEnvTools
online version:
schema: 2.0.0
---

# Import-DotEnvFile

## SYNOPSIS
Imports variables from one or more .env files into the current PowerShell process.

## SYNTAX

```
Import-DotEnvFile [-Path] <String> [-Scope <String>] [-Override] [-NoClobber] [-IncludeVariants]
 [-EnvironmentName <String>] [-SearchUp] [-Strict] [-ExpandVariables] [-PassThru] [-RevealValues]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Reads .env-formatted files and loads variables into the current process environment
through the PowerShell Env: provider.

The function resolves dotenv files using Get-DotEnvFilePath, then reads each file
with Read-DotEnvFile.

By default, values are imported exactly as written.
When -ExpandVariables is used,
references in the form ${NAME} are expanded using previously loaded dotenv values
first, then current process environment variables.
Missing references are preserved
unchanged.

## EXAMPLES

### EXAMPLE 1
```
Import-DotEnvFile -Path .\.env -WhatIf
```

### EXAMPLE 2
```
Import-DotEnvFile -Path .\.env -Verbose -PassThru
```

### EXAMPLE 3
```
Import-DotEnvFile -Path . -IncludeVariants -EnvironmentName development -Override -Verbose
```

### EXAMPLE 4
```
Import-DotEnvFile -Path .\.env -ExpandVariables -Override -Verbose
```

## PARAMETERS

### -EnvironmentName
Optional environment suffix used with variant files, such as development, test,
staging, production, or prod.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpandVariables
Expands ${NAME} references in values using already-loaded dotenv values first,
then current process environment variables.
Missing references are preserved.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeVariants
Includes supported variant files such as .env.local and .env.\<EnvironmentName\>
when resolving files.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoClobber
Do not overwrite existing environment variables.
This is the default behavior.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Override
Overwrite existing environment variables.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Returns import result records.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to a .env file or directory containing .env files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RevealValues
Shows actual values in PassThru output.
By default, non-empty values are masked.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope
Environment scope.
Currently only Process is supported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Process
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchUp
{{ Fill SearchUp Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Strict
Enables strict parsing behavior in the reader/parser.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Management.Automation.PSCustomObject
## NOTES
Windows PowerShell 5.1 compatible.
This command only writes to the current process environment.
Variable expansion is text-only and does not execute commands.

## RELATED LINKS
