@.github/AGENTS.md
@.github/copilot-instructions.md

# Claude Code

- このプロジェクトのスキルは .claude/skills/ に配置される。必要なスキルを優先して使う。
- 専門化された作業は .claude/agents/ の subagent に委譲してよい。統合支援は research-advisor、読み取り専用レビューは proposal-reviewer を優先する。
- すべての成果物は output/{project-name}/ 以下へ保存し、チャットには要約のみ残す。