# DotEnvTools Design Notes

DotEnvTools is intentionally conservative:

- `.env` files are data, not executable scripts.
- Process scope is the default and recommended target.
- Existing environment variables are preserved unless `-Override` is used.
- Auto-load is opt-in and should normally use `-TrustedPath`.
- Auto-load uses prompt wrapping because Windows PowerShell 5.1 has no native directory-change event hook.

## Parser scope

Supported:

- `KEY=value`
- `export KEY=value`
- `KEY="quoted value"`
- `KEY='literal value'`
- escaped double quotes inside double-quoted values
- common double-quoted escapes such as `\n`, `\t`, and `\\`
- quoted multiline values
- empty values
- full-line comments
- safe inline comments for unquoted values
- opt-in `${NAME}` variable expansion during import
- opt-in `$NAME` variable expansion during import

Not supported in this pass:

- command substitution
- implicit variable expansion
- encryption or secret synchronization
