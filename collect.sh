#!/usr/bin/env bash
set -euo pipefail

OUT=raw_data
CLONE_DIR=source_repos

mkdir -p "$OUT" "$CLONE_DIR"

# Map: repo URL → path inside repo to scan
declare -A SOURCES=(
  ["https://github.com/argoproj/argo-cd.git"]="master:docs"
  ["https://github.com/redhat-developer/gitops-operator.git"]="master:docs"
  ["https://github.com/openshift/openshift-docs.git"]="gitops-docs-main:"
)

LOCAL_SOURCES=()

for repo in "${!SOURCES[@]}"; do
  IFS=":" read -r branch subpath <<< "${SOURCES[$repo]}"

  name="$(basename "$repo" .git)"
  repo_dir="$CLONE_DIR/$name"

  if [[ -d "$repo_dir/.git" ]]; then
    git -C "$repo_dir" fetch origin
    git -C "$repo_dir" checkout "$branch"
    git -C "$repo_dir" pull --ff-only origin "$branch"
  else
    git clone --branch "$branch" --single-branch "$repo" "$repo_dir"
  fi


  target="$repo_dir/$subpath"
  if [[ -d "$target" ]]; then
    LOCAL_SOURCES+=("$target")
  else
    echo "Warning: path '$subpath' not found in $repo" >&2
  fi
done

echo "Collected sources"

if (( ${#LOCAL_SOURCES[@]} > 0 )); then
  find "${LOCAL_SOURCES[@]}" -type f \( -name "*.md" -o -name "*.adoc" \) |
  while read -r f; do
    rel="${f#$CLONE_DIR/}"
    dest="$OUT/$rel"
    mkdir -p "$(dirname "$dest")"
    cp "$f" "$dest"
  done
fi
echo "Copied sources to $OUT"
