---
name: git-commit-review
description: "Use when: reviewing staged git changes, grouping related modifications by topic, and creating clear English conventional commits for this repository."
---

# Git Commit Review

## Purpose

Use this skill when you need to inspect staged changes, separate them into logical groups, and create commits in English following the repository's preferred conventional commit style.

## Workflow

1. Review the current staged state.
   - Check git status and the staged diff summary.
   - Identify the main themes in the changes.

2. Group related changes by topic.
   - Prefer small, focused commits over one large commit.
   - Common groups may include player logic, camera behavior, animation, levels, or asset updates.

3. Draft commit messages in English.
   - Follow the pattern: type(scope): descriptive message with context
   - Prefer clear, specific wording over short labels.

4. Create the commits.
   - Stage each logical group separately.
   - Commit with the chosen English message.
   - Keep the history readable and coherent.

## Commit Style

Use concise but descriptive messages such as:

- refactor(player): apply stat-based movement and damage scaling
- refactor(camera): tune character camera pivots and collision handling
- refactor(animation): add timing controls for upper and lower body states
- chore(levels): update scene assets and level config defaults

## Notes

- Keep commits focused on a single concern.
- Prefer English for all commit messages.
- If a change touches multiple areas, split it into separate commits when it improves clarity.
