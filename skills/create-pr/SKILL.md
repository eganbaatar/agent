---
name: create-pr
description: Create draft pull requests and prepare commits that will go into them. Covers commit message format, PR titles, and draft status. Use when asked to open a PR or push changes for a PR.
---

# Create PR

## Commits and title

- If the repo enforces its own format (commitlint config, `CONTRIBUTING.md`), follow it.
  Otherwise use the rules below.
- Use Conventional Commits: `type(scope): summary`, imperative mood, max 72 characters.
- The PR title uses the same format as the main commit.
- Always open the PR as a draft.

## PR description

- If the user provides the final PR body, use it.
- Otherwise, if the `pr-description` skill is available, use it to draft the PR body from
  the actual diff and relevant context. Use the Markdown it returns as the PR body.
- If `pr-description` is unavailable, follow the repository's PR template and
  `CONTRIBUTING.md`. Write a concise summary of what changed and why. Include
  relevant test results and call out breaking changes.
