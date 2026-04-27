# Help Authoring

DotEnvTools uses comment-based help in `Source\DotEnvTools.psm1` as the source of truth for command help.

PlatyPS recreates Markdown help in `docs/reference`, then generates `Source\en-US\DotEnvTools-help.xml` for packaged `Get-Help` support.

## External Help

PowerShell external help files are MAML XML files placed under a culture folder such as `Source\en-US\DotEnvTools-help.xml`.

Best practice is not to edit generated help by hand. Update function comment-based help, then regenerate Markdown and XML:

```powershell
Install-Module platyPS -Scope CurrentUser
.\scripts\Update-DotEnvToolsHelp.ps1 -ModuleRoot . -Force
```

Commit the updated inline help, recreated Markdown, and generated XML when public command help changes.

The regeneration script removes and recreates `docs\reference` by default. Do not hand-edit Markdown files unless the script is changed to preserve them.
