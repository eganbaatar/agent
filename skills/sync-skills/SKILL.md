---
name: sync-skills
description: Sync the personal skills in this repo (`skills/*`) into the local agent skill folders by symlink, so edits in the repo are live. Use when the user says "sync my skills", "install my skills", "link my skills", after adding or removing a skill in this repo, or on a new machine.
---

# Sync skills

Syncs every skill in this repo's `skills/` folder into the local skill folders:

- `~/.agents/skills/<name>` -> `<repo>/skills/<name>` (the shared store; Codex reads it too)
- `~/.claude/skills/<name>` -> `../../.agents/skills/<name>`

Because these are symlinks, editing a skill in the repo takes effect immediately; re-running
the sync is only needed when a skill is added or removed.

## Run

Preview first, then apply:

```bash
bash scripts/sync.sh --dry-run
bash scripts/sync.sh
```

Run the script from this skill's directory (or pass its full path). It finds the repo from its
own location, so it works from any checkout.

## Never overwrite without asking

The script never replaces anything on its own. If a skill name is already taken in
`~/.agents/skills` or `~/.claude/skills` (a real folder, or a link to somewhere else, for
example a skill installed with `npx skills`), it prints a `conflict` line, skips that skill and
exits with code 3.

When that happens:

1. Show the user each `conflict` line and what the existing entry is.
2. Ask for permission to replace it, naming the skills. Do not assume a yes covers other skills.
3. Only after a clear yes, re-run with `--overwrite=<name>` for each approved skill, for
   example `bash scripts/sync.sh --overwrite=grill-me`. The old entry is moved to
   `~/.agents/skills-backup/<timestamp>/`, not deleted, so it can be restored.

## Behavior

- Idempotent: links that already point at the right place are left alone.
- Removes dangling links that pointed into this repo, so deleting a skill here and syncing
  cleans up the local folders.
- Does not touch `~/.agents/.skill-lock.json` or any skill it did not link.
- A skill is any `skills/<name>/` folder that contains a `SKILL.md`.

After syncing, tell the user which skills were linked, skipped, or replaced. A new skill shows
up in Claude Code at the start of the next session.
