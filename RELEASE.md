# Directory Structure Validator v1.0.0

Initial release of Directory Structure Validator, a lightweight GitHub Action for checking that required folders exist in a repository.

## Highlights

- Validate required directories such as `src`, `docs`, `tests`, `.github`, or `examples`.
- Accept newline, comma, or space-separated directory lists.
- Validate from the repository root or a custom `base-path`.
- Fail the workflow when directories are missing, or report missing directories without failing.
- Expose outputs for `valid`, `missing-directories`, and `checked-directories`.

## Example

```yaml
- name: Validate required directories
  uses: brandonhimpfen/directory-structure-validator@v1
  with:
    required-directories: |
      src
      docs
      tests
```