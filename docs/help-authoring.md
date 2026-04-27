# Help Authoring

DotEnvTools uses PlatyPS Markdown help in `docs/reference` as the reviewed source for external command help.

The generated MAML file lives at `Source\en-US\DotEnvTools-help.xml` and is included in the packaged module so `Get-Help` can read command help after import.

## External Help

PowerShell external help files are MAML XML files placed under a culture folder such as `Source\en-US\DotEnvTools-help.xml`.

Best practice is not to edit MAML by hand. Update the Markdown files, then regenerate the XML:

```powershell
Install-Module platyPS -Scope CurrentUser
.\scripts\Update-DotEnvToolsHelp.ps1 -ModuleRoot . -Force
```

Commit both the Markdown source and generated XML when public command help changes.

Comment-based help in `Source\DotEnvTools.psm1` should stay useful for maintainers, but external help is the packaged command help source.
