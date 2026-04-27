---
external help file: DotEnvTools-help.xml
Module Name: DotEnvTools
online version:
schema: 2.0.0
---

# Test-DotEnvGitIgnore

## SYNOPSIS
Checks whether common dotenv secret files are ignored by git.

## SYNTAX

```
Test-DotEnvGitIgnore [[-Path] <String>] [[-Patterns] <String[]>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Reads a repository .gitignore file and reports whether common dotenv patterns are present.

## EXAMPLES

### EXAMPLE 1
```
Test-DotEnvGitIgnore -Path .
```

## PARAMETERS

### -Path
Repository path.
Defaults to current directory.

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

### -Patterns
Patterns to require.
Defaults to .env, .env.*, and .env.keys.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @('.env', '.env.*', '.env.keys')
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Windows PowerShell 5.1 compatible.

## RELATED LINKS
