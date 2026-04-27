---
external help file: DotEnvTools-help.xml
Module Name: DotEnvTools
online version:
schema: 2.0.0
---

# Get-DotEnvFilePath

## SYNOPSIS
Resolves .env file paths in deterministic load order.

## SYNTAX

```
Get-DotEnvFilePath [-Path] <String> [-IncludeVariants] [-EnvironmentName <String>] [-SearchUp]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Returns existing .env files from either a direct .env file path or a directory path.
When -IncludeVariants is used, variant files are returned in precedence order:

\`.env\`, \`.env.local\`, \`.env.\<EnvironmentName\>\`, and \`.env.\<EnvironmentName\>.local\`.

Only existing files are returned.

## EXAMPLES

### EXAMPLE 1
```
Get-DotEnvFilePath -Path .\
```

### EXAMPLE 2
```
Get-DotEnvFilePath -Path .\ -IncludeVariants -EnvironmentName development
```

### EXAMPLE 3
```
Get-DotEnvFilePath -Path .\src -SearchUp
```

## PARAMETERS

### -EnvironmentName
Optional environment name, such as development, test, staging, or production.

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

### -IncludeVariants
Includes supported .env variant files.

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
A .env file path or directory path.

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

### -SearchUp
Searches parent directories for dotenv files and returns parent files before child files.

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

### System.String
## NOTES
Windows PowerShell 5.1 compatible.

## RELATED LINKS
