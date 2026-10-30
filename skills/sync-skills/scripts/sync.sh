#!/usr/bin/env bash
# Symlink this repo's skills/* into ~/.agents/skills (the shared store, also read by Codex),
# then into ~/.claude/skills.
# Usage: sync.sh [--dry-run] [--overwrite=<name>]...
# Anything already in the way is reported as a conflict and left alone (exit 3) unless it is
# named with --overwrite, in which case it is moved to ~/.agents/skills-backup first.
set -euo pipefail

dry_run=0
overwrite=" "
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    --overwrite=?*) overwrite+="${arg#--overwrite=} " ;;
    *) echo "usage: sync.sh [--dry-run] [--overwrite=<name>]..." >&2; exit 2 ;;
  esac
done

repo=$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." && pwd)
agents_dir="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
claude_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
backup_dir="${SKILLS_BACKUP_DIR:-$HOME/.agents/skills-backup}/$(date +%Y%m%d-%H%M%S)"
conflicts=0

run() { if [ "$dry_run" = 1 ]; then echo "  would: $*"; else "$@"; fi; }

# link <name> <target> <link>: create a symlink. An existing, different entry is a conflict:
# reported and skipped, unless <name> was passed to --overwrite (then backed up and replaced).
link() {
  local name=$1 target=$2 path=$3
  if [ -L "$path" ] && [ "$(readlink "$path")" = "$target" ]; then return 0; fi
  if [ -e "$path" ] || [ -L "$path" ]; then
    local what="a real folder or file"
    [ -L "$path" ] && what="a link to $(readlink "$path")"
    if [[ "$overwrite" != *" $name "* ]]; then
      echo "conflict $path is $what"
      conflicts=1
      return 1
    fi
    echo "backup $path -> $backup_dir/"
    run mkdir -p "$backup_dir"
    local owner; owner=$(basename "$(dirname "$(dirname "$path")")")
    run mv "$path" "$backup_dir/${owner#.}-$name"
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
  link "$name" "$repo/skills/$name" "$agents_dir/$name" || continue
  link "$name" "$rel/$name" "$claude_dir/$name" || true
done

remove_dangling "$agents_dir" "$repo/skills"
remove_dangling "$claude_dir" "$rel"

[ "$dry_run" = 1 ] && echo "done (dry run)" || echo "done"
if [ "$conflicts" = 1 ]; then
  echo "conflicts found: nothing was overwritten. Re-run with --overwrite=<name> after the user approves." >&2
  exit 3
fi
