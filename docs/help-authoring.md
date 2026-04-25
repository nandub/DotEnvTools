# Help Authoring

DotEnvTools currently uses comment-based help in `Source\DotEnvTools.psm1` as the source of truth for command help.

This is the right default while the module is still pre-1.0 because command documentation stays close to the function signatures and implementation. `Get-Help` can read comment-based help directly after the module is imported.

## External Help

PowerShell external help files are MAML XML files placed under a culture folder such as `Source\en-US\DotEnvTools-help.xml`.

Best practice is not to edit MAML by hand. If DotEnvTools needs external help later:

1. Author command help in Markdown.
2. Generate MAML XML from Markdown with a tool such as PlatyPS.
3. Commit both the Markdown source and generated XML.
4. Regenerate the XML when public command help changes.

Do not ship empty placeholder help XML files. They create packaging noise without improving `Get-Help`.
