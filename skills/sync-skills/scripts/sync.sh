#!/usr/bin/env bash
# Symlink this repo's skills/* into ~/.agents/skills and ~/.claude/skills.
set -euo pipefail

dry_run=0
[ "${1:-}" = "--dry-run" ] && dry_run=1

repo=$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." && pwd)
agents_dir="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
claude_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

run() { if [ "$dry_run" = 1 ]; then echo "  would: $*"; else "$@"; fi; }

# link <target> <link>: create or refresh a symlink, never clobber anything else.
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

run mkdir -p "$agents_dir" "$claude_dir"
# Relative path from the claude dir to the agents dir (../../.agents/skills by default).
[ -d "$claude_dir" ] && rel=$(realpath --relative-to="$claude_dir" "$agents_dir") || rel="../../.agents/skills"

for dir in "$repo"/skills/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  name=$(basename "$dir")
  link "$repo/skills/$name" "$agents_dir/$name" || continue
  link "$rel/$name" "$claude_dir/$name" || true
done

# Drop links whose skill no longer exists in this repo.
for path in "$agents_dir"/*; do
  [ -L "$path" ] || continue
  case "$(readlink "$path")" in
    "$repo"/skills/*) [ -e "$path" ] || { echo "remove $path (dangling)"; run rm "$path"; } ;;
  esac
done
for path in "$claude_dir"/*; do
  [ -L "$path" ] || continue
  case "$(readlink "$path")" in
    "$rel"/*) [ -e "$path" ] || { echo "remove $path (dangling)"; run rm "$path"; } ;;
  esac
done

[ "$dry_run" = 1 ] && echo "done (dry run)" || echo "done"
