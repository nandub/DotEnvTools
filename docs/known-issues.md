# Known Issues

- External MAML help is a placeholder; comment-based help is the source of truth in this pass.
- Auto-load depends on prompt invocation. It does not run while commands are executing.
- Variable expansion is opt-in through `Import-DotEnvFile -ExpandVariables`; implicit expansion remains unsupported.
- Multiline values are intentionally unsupported.
