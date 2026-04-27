---
external help file: DotEnvTools-help.xml
Module Name: DotEnvTools
online version:
schema: 2.0.0
---

# Initialize-DotEnvProject

## SYNOPSIS
Creates starter dotenv files for a project.

## SYNTAX

```
Initialize-DotEnvProject [[-Path] <String>] [[-Name] <String[]>] [[-Template] <String>]
 [[-EnvironmentName] <String>] [-IncludeVariants] [-ExampleOnly] [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates \`.env\`, \`.env.example\`, and optionally layered dotenv files in a target
directory.
Existing files are preserved unless -Force is used.

## EXAMPLES

### EXAMPLE 1
```
Initialize-DotEnvProject -Path . -Name API_URL,DB_NAME
```

### EXAMPLE 2
```
Initialize-DotEnvProject -Path . -Template WebApp -IncludeVariants
```

### EXAMPLE 3
```
Initialize-DotEnvProject -Path . -Name API_URL,DB_NAME -IncludeVariants -EnvironmentName development
```

## PARAMETERS

### -EnvironmentName
Optional environment suffix used for generated layer names.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Development
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExampleOnly
Creates only \`.env.example\`.

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

### -Force
Overwrites existing target files.

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
Creates \`.env.local\`, \`.env.\<EnvironmentName\>\`, and \`.env.\<EnvironmentName\>.local\`.

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

### -Name
Variable names to include in generated files.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @('API_URL', 'DB_NAME')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Target project directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: .
Accept pipeline input: False
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

### -Template
Starter template to use.
Basic uses -Name values.
WebApp creates common web
application placeholders.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Basic
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

## OUTPUTS

### System.IO.FileInfo
## NOTES
Windows PowerShell 5.1 compatible.

## RELATED LINKS
