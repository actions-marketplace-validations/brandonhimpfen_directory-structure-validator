# Directory Structure Validator

Directory Structure Validator is a lightweight GitHub Action that checks whether required folders exist in a repository.

It is useful for enforcing a consistent project layout across repositories, templates, starter kits, open source projects, documentation sites, and internal codebases.

## What It Checks

The action verifies that required directories exist relative to a configurable base path.

Common examples include:

- `src`
- `docs`
- `tests`
- `config`
- `.github`
- `examples`

If one or more required directories are missing, the action can fail the workflow or report the missing directories without failing.

## Usage

Create a workflow file such as `.github/workflows/directory-structure-validator.yml`:

```yaml
name: Directory Structure Validator

on:
  pull_request:
  push:
    branches:
      - main

jobs:
  validate-directories:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Validate required directories
        uses: brandonhimpfen/directory-structure-validator@v1
        with:
          required-directories: |
            src
            docs
            tests
```

Replace `brandonhimpfen/directory-structure-validator@v1` with the published action path.

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `required-directories` | Newline, comma, or space-separated list of required directories. | No | `src docs` |
| `base-path` | Base path to validate from. | No | `.` |
| `fail-on-missing` | Whether the workflow should fail when required directories are missing. | No | `true` |
| `allow-empty` | Whether an empty `required-directories` value is allowed. | No | `false` |

## Outputs

| Output | Description |
| --- | --- |
| `valid` | `true` when all required directories exist; `false` otherwise. |
| `missing-directories` | Comma-separated list of missing directories. |
| `checked-directories` | Comma-separated list of directories checked. |

## Examples

### Require Common Project Folders

```yaml
- name: Validate required directories
  uses: brandonhimpfen/directory-structure-validator@v1
  with:
    required-directories: |
      src
      docs
      tests
```

### Use a Comma-Separated List

```yaml
- name: Validate required directories
  uses: brandonhimpfen/directory-structure-validator@v1
  with:
    required-directories: src,docs,tests,examples
```

### Validate a Subdirectory

```yaml
- name: Validate package directories
  uses: brandonhimpfen/directory-structure-validator@v1
  with:
    base-path: packages/app
    required-directories: |
      src
      public
      tests
```

### Report Missing Directories Without Failing

```yaml
- name: Check directory structure
  id: directory-check
  uses: brandonhimpfen/directory-structure-validator@v1
  with:
    required-directories: |
      src
      docs
      tests
    fail-on-missing: false

- name: Print missing directories
  if: steps.directory-check.outputs.valid == 'false'
  run: echo "Missing directories: ${{ steps.directory-check.outputs.missing-directories }}"
```

### Require GitHub Community Files

```yaml
- name: Validate repository support directories
  uses: brandonhimpfen/directory-structure-validator@v1
  with:
    required-directories: |
      .github
      docs
```

## Path Handling

Directory names may be provided with or without a leading slash.

These are treated the same:

```text
src
/src
src/
```

The action checks for directories only. It does not check for files.

## Recommended Version Pinning

For most workflows, pin the action to the stable major version:

```yaml
uses: brandonhimpfen/directory-structure-validator@v1
```

For stricter reproducibility, pin to a full release version:

```yaml
uses: brandonhimpfen/directory-structure-validator@v1.0.0
```

## License

This project is licensed under the MIT License.
