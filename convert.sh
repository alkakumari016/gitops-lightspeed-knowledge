#!/usr/bin/env bash
set -euo pipefail

IN="raw_data"
OUT="data"
mkdir -p "$OUT"

#find "$IN" -type f -name "*.md" -exec cp --parents {} "$OUT" \;
find "$IN" -type f -name "*.md" | while IFS= read -r f; do
  rel="${f#$IN/}"
  dest="$OUT/$rel"
  mkdir -p "$(dirname "$dest")"
  cp "$f" "$dest"
done

echo "Copied .md files"

command -v asciidoctor >/dev/null || {
  echo "Error: asciidoctor is required to convert .adoc files" >&2
  exit 1
}
find "$IN" -type f -name "*.adoc" | while IFS= read -r f; do
  out="${f#$IN/}"
  # repo root = first path segment
  repo_root="$IN/${out%%/*}"
  out="${out%.adoc}.md"
  mkdir -p "$(dirname "$OUT/$out")"

  asciidoctor \
    -B "$repo_root" \
    -b docbook \
    "$f" -o - | \
  pandoc -f docbook -t markdown_strict  -o "$OUT/$out"
done
echo "Converted .adoc files"