---
name: pr-description
description: Draft or update a Markdown pull request description for a bugfix, feature, or other change. Use when asked to write or revise a PR body or when create-pr needs a description.
---

# PR Description

## Precedence

- Always use the structure in this skill, unless the repo's PR template or
  `CONTRIBUTING.md` explicitly says how to write the description (required sections or
  guidance for the description text). A template that only has a checklist, labels, or links
  does not count: keep those parts of the template, and write the description with this
  skill's structure.

## Writing style for every description

- Write for a human reviewer who wants to understand the change quickly.
- Keep it tight. No filler, no restating the diff line by line, no deep implementation detail.
- If the solution is technical, start with a one- or two-sentence TL;DR, then the detail.

## Bugfix (`fix:`)

Use three sections:

```markdown
## Bug

What is broken, as the user or system experiences it.

## Cause

Why it happens.

## Fix

What was changed to fix it.
```

**Small bugs:** if each section would only be a few words (typo, off-by-one, missing null
check, obvious one-line cause), skip the sections and write one short paragraph covering bug,
cause, and fix.

Example of a small bugfix description:

> The export button stayed disabled after a failed upload because the error handler never
> reset the loading flag. The flag is now reset in `finally`.

## Feature (`feat:`)

```markdown
## Summary

The requirement behind this change, in plain language: what users or the
system can now do, and why.

## Changes

What changed. Put the most important changes first and mark breaking changes
clearly, e.g. **Breaking:** `GET /items` now requires pagination params.

## Tests

What test coverage was added or updated, and anything not covered.
```

## Other types (`refactor:`, `chore:`, `docs:`, `ci:`)

Write one short paragraph: what changed and why. Mention explicitly if behavior is unchanged.

## Before submitting

- The description matches the actual diff; nothing claimed that isn't in it.
- Breaking changes are visible without reading the whole description.
- Small bugfixes are a single paragraph, not three thin sections.
