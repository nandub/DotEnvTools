---
external help file: DotEnvTools-help.xml
Module Name: DotEnvTools
online version:
schema: 2.0.0
---

# Test-DotEnvFile

## SYNOPSIS
Validates .env file syntax and optional .env.example coverage.

## SYNTAX

```
Test-DotEnvFile [-Path] <String> [[-ExamplePath] <String>] [[-Required] <String[]>] [-RequireNoExtraKeys]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Parses a .env file in strict mode and optionally verifies that keys from an example file exist.

## EXAMPLES

### EXAMPLE 1
```
Test-DotEnvFile -Path .\.env -ExamplePath .\.env.example
```

### EXAMPLE 2
```
Test-DotEnvFile -Path .\.env -ExamplePath .\.env.example -Required API_URL,DB_NAME -RequireNoExtraKeys
```

## PARAMETERS

### -ExamplePath
Optional .env.example path.

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

### -Path
Path to .env file.

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

### -Required
Specific variable names expected in the dotenv file.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequireNoExtraKeys
Warns when the dotenv file contains keys that are not present in the example file.

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
