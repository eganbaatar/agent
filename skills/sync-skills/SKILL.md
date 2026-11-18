---
name: sync-skills
description: Sync personal skills from a managed checkout of eganbaatar/agent into local agent skill folders by symlink. Use when the user says "sync my skills", "install my skills", "link my skills", after adding or removing a skill in this repo, or on a new machine.
---

# Sync skills

Syncs every skill in this repo's `skills/` folder into the local skill folders:

- `~/.agents/skills/<name>` -> `<repo>/skills/<name>` (the shared store; Codex reads it too)
- `~/.claude/skills/<name>` -> `../../.agents/skills/<name>`

Keep the managed checkout in the user's data directory, not `/tmp`: installed symlinks
(including `/sync-skills` itself) need their targets to survive restarts and cache cleanup.

## Run

From any directory, prepare the managed checkout and preview its link changes:

```bash
(
  set -e
  repo="${XDG_DATA_HOME:-$HOME/.local/share}/sync-skills/agent"
  url=https://github.com/eganbaatar/agent.git
  if [ ! -e "$repo" ] && [ ! -L "$repo" ]; then
    mkdir -p "$(dirname "$repo")"
    git clone --branch main --single-branch "$url" "$repo"
  elif [ ! -d "$repo/.git" ] || [ "$(git -C "$repo" remote get-url origin)" != "$url" ] ||
       [ "$(git -C "$repo" symbolic-ref --short HEAD)" != main ]; then
    echo "Unexpected checkout at $repo; leaving it alone" >&2
    exit 1
  else
    git -C "$repo" pull --ff-only origin main
  fi
  bash "$repo/skills/sync-skills/scripts/sync.sh" --dry-run
)
```

If checkout preparation fails, stop and show the error; never fall back to a stale clone.
After reviewing the preview, apply from the same checkout:

```bash
repo="${XDG_DATA_HOME:-$HOME/.local/share}/sync-skills/agent"
bash "$repo/skills/sync-skills/scripts/sync.sh"
```

Existing links into a developer checkout are conflicts, not permission to migrate them silently.

## Never overwrite without asking

The script never replaces anything on its own. If a skill name is already taken in
`~/.agents/skills` or `~/.claude/skills` (a real folder, or a link to somewhere else, for
example a skill installed with `npx skills`), it prints a `conflict` line, skips that skill and
exits with code 3.

When that happens:

1. Show the user each `conflict` line and what the existing entry is.
2. Ask for permission to replace it, naming the skills. Do not assume a yes covers other skills.
3. Only after a clear yes, re-run with `--overwrite=<name>` for each approved skill, for
   example `bash "$repo/skills/sync-skills/scripts/sync.sh" --overwrite=grill-me`. The old entry is moved to
   `~/.agents/skills-backup/<timestamp>/`, not deleted, so it can be restored.

## Behavior

- Idempotent: links that already point at the right place are left alone.
- Removes dangling links that pointed into this repo, so deleting a skill here and syncing
  cleans up the local folders.
- Does not touch `~/.agents/.skill-lock.json` or any skill it did not link.
- A skill is any `skills/<name>/` folder that contains a `SKILL.md`.

After syncing, tell the user which skills were linked, skipped, or replaced. A new skill shows
up in Claude Code at the start of the next session.
