#!/usr/bin/env bash
# Prints the CHANGELOG.md section for a version, e.g. `tool/release_notes.sh 1.0.1`.
# Exits non-zero when the section is missing or empty, so a release can't go
# out without notes.
set -euo pipefail

version="${1:?usage: release_notes.sh <version> [changelog]}"
file="${2:-CHANGELOG.md}"

notes=$(awk -v v="$version" '
  /^## / { if (found) exit; if ($2 == v) { found = 1; next } }
  found { print }
' "$file")

if [ -z "$(printf '%s' "$notes" | tr -d '[:space:]')" ]; then
  echo "No release notes for $version: add a '## $version' section to $file" >&2
  exit 1
fi
printf '%s\n' "$notes"
