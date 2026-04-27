---
external help file: DotEnvTools-help.xml
Module Name: DotEnvTools
online version:
schema: 2.0.0
---

# Get-DotEnvValue

## SYNOPSIS
Gets one dotenv value without modifying the process environment.

## SYNTAX

```
Get-DotEnvValue [-Path] <String> [-Name] <String> [-IncludeVariants] [[-EnvironmentName] <String>] [-SearchUp]
 [-Strict] [-ExpandVariables] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads resolved dotenv files and returns the value for a single key.
This command
does not write to the process environment.

## EXAMPLES

### EXAMPLE 1
```
Get-DotEnvValue -Path .\.env -Name API_URL
```

### EXAMPLE 2
```
Get-DotEnvValue -Path . -Name API_URL -IncludeVariants -EnvironmentName development -ExpandVariables
```

## PARAMETERS

### -EnvironmentName
Optional environment suffix used with variant files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpandVariables
Expands variable references before returning the value.

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
Includes supported variant files.

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
Variable name to return.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to a .env file or directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
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

### -SearchUp
Searches parent directories for dotenv files.

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
Enables strict parsing.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES
Windows PowerShell 5.1 compatible.

## RELATED LINKS
