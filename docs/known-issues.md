# Known Issues

- External MAML help is a placeholder; comment-based help is the source of truth in this pass.
- Auto-load depends on prompt invocation. It does not run while commands are executing.
- Variable expansion is opt-in through `Import-DotEnvFile -ExpandVariables`; implicit expansion remains unsupported.
- Command substitution and encryption are intentionally unsupported.
- Dotenv file editing commands preserve unrelated lines, but they do not preserve inline comments on a line whose key is replaced.
