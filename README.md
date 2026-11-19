# Agent skills

## Use these skills with Codex in Zed

Codex in Zed reads local skill folders. Skills saved in ChatGPT’s Skills tab are managed separately.

1. Clone this repository to a permanent location.
2. From the repository root, preview and apply the sync.

   ```bash
   bash skills/sync-skills/scripts/sync.sh --dry-run
   bash skills/sync-skills/scripts/sync.sh
   ```

   The script links each skill into `~/.agents/skills/` for Codex and also sets up links in `~/.claude/skills/` for Claude Code. Keep the checkout in place so the links stay valid.

3. Start a Codex thread in Zed and ask it to use `pr-description` to draft a pull request description. When you ask `create-pr` to open a pull request, it uses `pr-description` when available.

4. With Linear access configured in Codex, ask it to use `brief-core-data` for your Core Data daily briefing.

Pull changes in the checkout to update existing skills. Rerun the sync when a skill folder is added or removed.

[Codex skill discovery](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills) · [Codex in Zed](https://zed.dev/docs/ai/external-agents#codex)
