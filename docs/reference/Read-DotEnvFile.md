---
external help file: DotEnvTools-help.xml
Module Name: DotEnvTools
online version:
schema: 2.0.0
---

# Read-DotEnvFile

## SYNOPSIS
Reads a .env file and returns normalized key/value records.

## SYNTAX

```
Read-DotEnvFile [-Path] <String> [-Strict] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reads a single .env file, parses it with ConvertFrom-DotEnv, and returns one object
per environment variable with Name, Value, and SourcePath properties.

This function normalizes null values to empty strings so EMPTY_VALUE= remains an
empty environment variable rather than being treated as a missing value.

## EXAMPLES

### EXAMPLE 1
```
Read-DotEnvFile -Path .\.env
```

### EXAMPLE 2
```
Read-DotEnvFile -Path .\.env -Strict
```

## PARAMETERS

### -Path
Path to a .env file.

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

### -Strict
Reports invalid .env lines as errors.

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

### System.String
## OUTPUTS

### System.Management.Automation.PSCustomObject
## NOTES
Windows PowerShell 5.1 compatible.

## RELATED LINKS
