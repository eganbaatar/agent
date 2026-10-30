---
name: sync-skills
description: Sync the personal skills in this repo (`skills/*`) into the local agent skill folders by symlink, so edits in the repo are live. Use when the user says "sync my skills", "install my skills", "link my skills", after adding or removing a skill in this repo, or on a new machine.
---

# Sync skills

Links every skill in this repo's `skills/` folder into the local agent skill folders:

- `~/.agents/skills/<name>` -> `<repo>/skills/<name>` (the shared store, always written)
- `~/.claude/skills/<name>` -> `../../.agents/skills/<name>` (`--claude`)
- `~/.codex/skills/<name>` -> `../../.agents/skills/<name>` (`--codex`, honors `$CODEX_HOME`)

Because these are symlinks, editing a skill in the repo takes effect immediately; re-running
the sync is only needed when a skill is added or removed.

## Run

Pick the agent with `--claude` and/or `--codex`; with neither flag, both are synced. Preview
first with `--dry-run`, then apply:

```bash
bash scripts/sync.sh --claude --dry-run
bash scripts/sync.sh --claude
```

Run the script from this skill's directory (or pass its full path). It finds the repo from its
own location, so it works from any checkout.

## Behavior

- Idempotent: links that already point at the right place are left alone.
- Never overwrites a real file or folder, or a link that points somewhere else (for example a
  skill installed by `npx skills`). It prints a warning and skips that skill. Resolve the
  conflict by hand, then re-run.
- Removes dangling links that pointed into this repo, so deleting a skill here and syncing
  cleans up the local folders.
- Does not touch `~/.agents/.skill-lock.json` or any skill it did not link.
- A skill is any `skills/<name>/` folder that contains a `SKILL.md`.

After syncing, tell the user which skills were linked, skipped, or removed. A new skill shows
up in Claude Code at the start of the next session.
