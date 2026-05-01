#!/usr/bin/env bash
set -euo pipefail

required_directories="${INPUT_REQUIRED_DIRECTORIES:-}"
base_path="${INPUT_BASE_PATH:-.}"
fail_on_missing="${INPUT_FAIL_ON_MISSING:-true}"
allow_empty="${INPUT_ALLOW_EMPTY:-false}"

normalize_bool() {
  local value
  value="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$value" in
    true|1|yes|y) printf 'true' ;;
    false|0|no|n) printf 'false' ;;
    *)
      echo "::error::Invalid boolean value '$1'. Use true or false."
      exit 2
      ;;
  esac
}

fail_on_missing="$(normalize_bool "$fail_on_missing")"
allow_empty="$(normalize_bool "$allow_empty")"

if [[ ! -d "$base_path" ]]; then
  echo "::error::Base path '$base_path' does not exist or is not a directory."
  exit 1
fi

# Accept newline, comma, or whitespace-separated values.
mapfile -t directories < <(
  printf '%s\n' "$required_directories" |
    tr ',' '\n' |
    awk '{$1=$1}; NF {print}'
)

# Split lines that still contain whitespace-separated values.
expanded=()
for entry in "${directories[@]}"; do
  # shellcheck disable=SC2206
  parts=( $entry )
  for part in "${parts[@]}"; do
    expanded+=("$part")
  done
done

directories=("${expanded[@]}")

if [[ ${#directories[@]} -eq 0 ]]; then
  if [[ "$allow_empty" == "true" ]]; then
    echo "No required directories were provided."
    {
      echo "valid=true"
      echo "missing-directories="
      echo "checked-directories="
    } >> "$GITHUB_OUTPUT"
    exit 0
  fi

  echo "::error::No required directories were provided. Set allow-empty to true to permit this."
  exit 1
fi

missing=()
checked=()

for directory in "${directories[@]}"; do
  cleaned="${directory#/}"
  cleaned="${cleaned%/}"

  if [[ -z "$cleaned" ]]; then
    continue
  fi

  checked+=("$cleaned")
  target="$base_path/$cleaned"

  if [[ -d "$target" ]]; then
    echo "Directory exists: $cleaned"
  else
    echo "::warning::Missing required directory: $cleaned"
    missing+=("$cleaned")
  fi
done

join_by_comma() {
  local IFS=','
  printf '%s' "$*"
}

missing_csv="$(join_by_comma "${missing[@]:-}")"
checked_csv="$(join_by_comma "${checked[@]:-}")"

if [[ ${#missing[@]} -eq 0 ]]; then
  echo "All required directories exist."
  valid="true"
else
  echo "Missing directories: $missing_csv"
  valid="false"
fi

{
  echo "valid=$valid"
  echo "missing-directories=$missing_csv"
  echo "checked-directories=$checked_csv"
} >> "$GITHUB_OUTPUT"

if [[ "$valid" == "false" && "$fail_on_missing" == "true" ]]; then
  exit 1
fi
