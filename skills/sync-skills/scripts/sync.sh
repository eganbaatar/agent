#!/usr/bin/env bash
# Symlink this repo's skills/* into ~/.agents/skills (the shared store, also read by Codex),
# then into ~/.claude/skills. Usage: sync.sh [--dry-run]
set -euo pipefail

dry_run=0
case "${1:-}" in
  "") ;;
  --dry-run) dry_run=1 ;;
  *) echo "usage: sync.sh [--dry-run]" >&2; exit 2 ;;
esac

repo=$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." && pwd)
agents_dir="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
claude_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

run() { if [ "$dry_run" = 1 ]; then echo "  would: $*"; else "$@"; fi; }

# link <target> <link>: create a symlink, never clobber anything else.
link() {
  local target=$1 path=$2
  if [ -L "$path" ]; then
    [ "$(readlink "$path")" = "$target" ] && return 0
    echo "skip   $path -> $(readlink "$path") (points elsewhere)"
    return 1
  elif [ -e "$path" ]; then
    echo "skip   $path (exists and is not a symlink)"
    return 1
  fi
  if [ "$dry_run" = 1 ]; then echo "would link $path -> $target"; else ln -s "$target" "$path"; echo "link   $path -> $target"; fi
}

# remove_dangling <dir> <target-prefix>: drop links in <dir> into <target-prefix> whose target is gone.
remove_dangling() {
  local dir=$1 prefix=$2 path
  for path in "$dir"/*; do
    [ -L "$path" ] || continue
    case "$(readlink "$path")" in
      "$prefix"/*) [ -e "$path" ] || { echo "remove $path (dangling)"; run rm "$path"; } ;;
    esac
  done
}

run mkdir -p "$agents_dir" "$claude_dir"
# Relative path from the claude dir to the store (../../.agents/skills by default).
if [ -d "$claude_dir" ]; then rel=$(realpath --relative-to="$claude_dir" "$agents_dir"); else rel="../../.agents/skills"; fi

for dir in "$repo"/skills/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  name=$(basename "$dir")
  link "$repo/skills/$name" "$agents_dir/$name" || continue
  link "$rel/$name" "$claude_dir/$name" || true
done

remove_dangling "$agents_dir" "$repo/skills"
remove_dangling "$claude_dir" "$rel"

[ "$dry_run" = 1 ] && echo "done (dry run)" || echo "done"
