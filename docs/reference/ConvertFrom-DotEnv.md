---
external help file: DotEnvTools-help.xml
Module Name: DotEnvTools
online version:
schema: 2.0.0
---

# ConvertFrom-DotEnv

## SYNOPSIS
Parses .env content into a PowerShell object.

## SYNTAX

### Path (Default)
```
ConvertFrom-DotEnv -Path <String> [-Strict] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Content
```
ConvertFrom-DotEnv -Content <String> [-Strict] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Parses .env content from a file path or raw content string and returns a PSCustomObject
where each .env key becomes a property.

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-DotEnv -Path .\.env
```

### EXAMPLE 2
```
ConvertFrom-DotEnv -Content "KEY=value"
```

## PARAMETERS

### -Content
Raw .env content.

```yaml
Type: String
Parameter Sets: Content
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Path to a .env file.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: Named
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

### -Strict
Reports invalid .env lines as errors instead of silently skipping them.

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
