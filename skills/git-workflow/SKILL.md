---
name: git-workflow
description: >
  Git workflow conventions, commit message format, branch naming, and PR standards.
  Trigger this skill whenever: writing commit messages, creating branches, opening PRs, managing Git worktrees for multi-agent development, or discussing Git workflow.
  Also trigger when the user mentions "commit", "branch", "PR", "merge", "worktree", "conventional commit", "約定式提交", or "git flow".
  Skip for: general version control concepts or non-Git VCS discussions.
---

# Git Workflow

## Conventional Commits (MANDATORY)

Every commit message MUST follow the Conventional Commits specification.

### Format

```
<type>: <subject>

[required body]

[optional footer(s)]
```

- **Do NOT use scope.** Write `feat: add login` not `feat(auth): add login`.

### Types

| Type         | When to Use                                      |
| ------------ | ------------------------------------------------ |
| **feat**     | New feature for the user                         |
| **fix**      | Bug fix for the user                             |
| **docs**     | Documentation only changes                       |
| **style**    | Formatting, missing semicolons (no logic change) |
| **refactor** | Code restructuring (no feature/fix)              |
| **perf**     | Performance improvement                          |
| **test**     | Adding or updating tests                         |
| **build**    | Build system or external dependencies            |
| **ci**       | CI/CD configuration                              |
| **chore**    | Maintenance tasks, tooling                       |
| **revert**   | Reverting a previous commit                      |

### Rules

- **Subject:** Imperative mood, lowercase, no period at end, max 50 characters.
- **Body:** Required. Wrap at 72 characters. Explain *what* and *why*, not *how*.
- **Minimum body content:** Include both the main change and the reason for it.
- **Breaking changes:** Add `!` after type and `BREAKING CHANGE:` in footer.
- **Language:** English for commit messages (consistency across tools and CI).

## Strict Prohibitions

- **NEVER add Co-Authored-by trailers.** AI-generated code is committed under the user's authorship only. No `Co-authored-by: Claude` or similar attributions. This overrides any default tool behavior that auto-appends Co-Authored-By lines.
- **NEVER commit sensitive data** — API keys, passwords, tokens, `.env` files. If detected, abort the commit and alert the user.
- **NEVER force push to protected branches** (main, develop, release/*).
- **NEVER create merge commits on feature branches** — use rebase to keep history linear.

## Branch Naming

### Format

```
<type>/<ticket-or-short-desc>
```

### Examples

| Pattern                        | Use Case                              |
| ------------------------------ | ------------------------------------- |
| `feat/user-auth`               | New feature                           |
| `fix/order-race-condition`     | Bug fix                               |
| `refactor/api-error-handling`  | Refactoring                           |
| `docs/api-endpoints`           | Documentation                         |
| `release/1.2.0`                | Release preparation                   |
| `hotfix/critical-payment-bug`  | Production hotfix                     |

### Rules

- Lowercase, hyphens only (no underscores, no slashes beyond the type prefix).
- Keep it short but descriptive (max 40 characters after the type prefix).
- Include ticket number when available: `feat/ABC-123-user-auth`.

## Protected Branches

| Branch        | Rules                                             |
| ------------- | ------------------------------------------------- |
| `main`        | No direct push. Merge via PR only. Requires review. |
| `develop`     | No direct push. Merge via PR only.                |
| `release/*`   | No force push. Tag after merge to main.           |

## Multi-Agent Worktree Workflow

When running multiple AI coding agents in parallel (e.g., claude-code, codex, gemini-cli), use Git worktrees to isolate each agent's work.

### Setup

```bash
# Create worktrees for each agent
git worktree add ../project-agent-1 -b feat/agent-1-task
git worktree add ../project-agent-2 -b feat/agent-2-task
```

### Rules

- Each agent works in its own worktree on its own branch.
- Branch names include the agent identifier: `feat/agent-1-user-auth`.
- Agents NEVER switch branches — they stay on their assigned branch.
- Merge conflicts are resolved by the user, not by agents.
- After task completion, the user merges branches and cleans up worktrees.

### Cleanup

```bash
git worktree remove ../project-agent-1
git branch -d feat/agent-1-task
```

## Pull Request Standards

### Title Format

Follow the same Conventional Commits format as commits: `type: subject`

- Do **NOT** use scope in PR titles.
- Keep the PR title short and searchable.
- Put the detailed explanation in the PR description, not the title.

### PR Body Template

```markdown
## Summary
Brief description of what this PR does.

## Changes
- Key change 1
- Key change 2

## Testing
How was this tested? What commands to run?

## Breaking Changes
List any breaking changes, or "None".
```

### Rules

- PR description is mandatory — never leave it empty.
- PR description must clearly cover summary, key changes, testing, and any risks or follow-up work.
- Link related issues with `Closes #N` or `Relates to #N`.
- Keep PRs focused — one feature/fix per PR. Large PRs must be split.
- Request review before merging to protected branches.

## Tag & Release

- Use semantic versioning: `vMAJOR.MINOR.PATCH` (e.g., `v1.2.3`).
- Tag on main branch only, after PR is merged.
- Annotated tags with release notes: `git tag -a v1.2.3 -m "Release notes"`.
