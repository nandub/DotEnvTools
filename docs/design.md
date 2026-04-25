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
- `KEY="quoted value"`
- `KEY='literal value'`
- empty values
- full-line comments
- safe inline comments for unquoted values

Not supported in this pass:

- multiline values
- command substitution
- implicit variable expansion
