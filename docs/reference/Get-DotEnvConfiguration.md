---
external help file: DotEnvTools-help.xml
Module Name: DotEnvTools
online version:
schema: 2.0.0
---

# Get-DotEnvConfiguration

## SYNOPSIS
Gets dotenv configuration without modifying the process environment.

## SYNTAX

```
Get-DotEnvConfiguration [-Path] <String> [-IncludeVariants] [[-EnvironmentName] <String>] [-SearchUp] [-Strict]
 [-ExpandVariables] [-AsHashtable] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Resolves one or more dotenv files and returns a PSCustomObject by default, or an
ordered hashtable when -AsHashtable is used.

## EXAMPLES

### EXAMPLE 1
```
Get-DotEnvConfiguration -Path .\.env
```

### EXAMPLE 2
```
Get-DotEnvConfiguration -Path . -IncludeVariants -EnvironmentName development -AsHashtable
```

## PARAMETERS

### -AsHashtable
Returns an ordered hashtable instead of a PSCustomObject.

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

### -EnvironmentName
Optional environment suffix used with variant files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpandVariables
Expands variable references using values already read, then process variables.

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
Searches parent directories for dotenv files, loading parents before children.

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

### System.Management.Automation.PSObject
### System.Collections.Specialized.OrderedDictionary
## NOTES
Windows PowerShell 5.1 compatible.

## RELATED LINKS
