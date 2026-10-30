#!/usr/bin/env bash
# Symlink this repo's skills/* into ~/.agents/skills, then into each selected agent's skill folder.
# Usage: sync.sh [--claude] [--codex] [--dry-run]   (no agent flag = all agents)
set -euo pipefail

dry_run=0 want_claude=0 want_codex=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    --claude) want_claude=1 ;;
    --codex) want_codex=1 ;;
    *) echo "usage: sync.sh [--claude] [--codex] [--dry-run]" >&2; exit 2 ;;
  esac
done
[ "$want_claude$want_codex" = "00" ] && want_claude=1 want_codex=1

repo=$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." && pwd)
agents_dir="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
agent_dirs=()
[ "$want_claude" = 1 ] && agent_dirs+=("${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}")
[ "$want_codex" = 1 ] && agent_dirs+=("${CODEX_SKILLS_DIR:-${CODEX_HOME:-$HOME/.codex}/skills}")

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

run mkdir -p "$agents_dir" "${agent_dirs[@]}"

# Per agent folder: relative path to the shared store (../../.agents/skills for ~/.claude/skills).
rels=()
for d in "${agent_dirs[@]}"; do
  if [ -d "$d" ]; then rels+=("$(realpath --relative-to="$d" "$agents_dir")"); else rels+=("../../.agents/skills"); fi
done

for dir in "$repo"/skills/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  name=$(basename "$dir")
  link "$repo/skills/$name" "$agents_dir/$name" || continue
  for i in "${!agent_dirs[@]}"; do link "${rels[$i]}/$name" "${agent_dirs[$i]}/$name" || true; done
done

remove_dangling "$agents_dir" "$repo/skills"
for i in "${!agent_dirs[@]}"; do remove_dangling "${agent_dirs[$i]}" "${rels[$i]}"; done

[ "$dry_run" = 1 ] && echo "done (dry run)" || echo "done"
