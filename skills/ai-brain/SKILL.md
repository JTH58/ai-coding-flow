---
name: ai-brain
description: >
  Long-term memory system using Git-versioned Markdown files. Manages Project Brain
  (project-specific decisions, issues, logs) and Common Brain (cross-project knowledge).
  This skill is ALWAYS active — it loads in every conversation to ensure context continuity.
  Owns journal.md and known_issues.md write-back. Other Brain files are written by their
  owning Skills. The user mentions "Brain", "記憶", "記錄", "architecture decisions" to
  interact with it explicitly, but it runs in the background even without explicit mention.
hooks:
  Stop:
    - matcher: "*"
      hooks:
        - type: prompt
          prompt: >
            Review the assistant's last message and tool calls to determine if code or config
            was written/modified (Edit, Write, or NotebookEdit tool calls on project files).
            "Project files" = files under the current working directory.
            Files under the ai-brain directory (Brain data) are NOT project files — ignore them.

            Rules:
            1. If stop_hook_active is true, respond {"ok": true}
            2. If no code/config was written (discussion, Q&A, clarification, planning),
               respond {"ok": true}
            3. If code/config was written AND there is an Edit/Write tool call targeting
               journal.md, respond {"ok": true}
            4. If code/config was written but NO Edit/Write tool call targeted journal.md,
               respond {"ok": false, "reason": "You wrote code/config but did not update
               journal.md. Add a one-line entry to $BRAIN_ROOT/$PROJECT_NAME/journal.md
               describing what was done."}
---

# AI Brain Protocol

## Paths

Derive all paths from `$PWD`. Never hardcode absolute paths or usernames.

```bash
PROJECT_NAME=$(basename "$PWD")
BRAIN_ROOT="$(dirname "$PWD")/ai-brain"
```

| Path               | Location                             |
| ------------------ | ------------------------------------ |
| Project Brain      | `$BRAIN_ROOT/$PROJECT_NAME/`         |
| Common Brain       | `$BRAIN_ROOT/_common/`               |
| Project Template   | `$BRAIN_ROOT/_example/`              |

## Brain Structure

### Project Brain

| File                        | Purpose                                           |
| --------------------------- | ------------------------------------------------- |
| `architecture_decisions.md` | Hard constraints, tech stack, domain model         |
| `todo.md`                   | Active tasks, future plans, backlog                |
| `known_issues.md`           | Bugs, technical debt, workarounds                  |
| `journal.md`                | Daily logs, progress notes                         |

New projects: copy templates from `$BRAIN_ROOT/_example/`.

### Common Brain — Tiered

| Tier | Files | Strategy |
|------|-------|----------|
| Tier 2 | `skill-experience.md` | Path listed at load; read when needed |
| Tier 3 | `preferences.md`, `troubleshooting.md`, `toolchain.md` | Path listed at load; read on demand |

Skill-owned files (not tiered): `conversation-patterns.md` (conversation-logger), `prompt-violations.md` (prompt-engineer).

## Loading Procedure

Execute on the first message of every conversation. Skip only if user says "skip Brain".

### Hook path (Claude Code)

If `=== AI BRAIN ===` marker is present in context, the SessionStart hook has already injected:
- **Tier 1 (MUST READ):** `architecture_decisions.md` + `known_issues.md` full text — already in context.
- **Tier 2 (AVAILABLE):** `todo.md`, `journal.md`, `skill-experience.md` paths listed.
- **Tier 3 (ON DEMAND):** `_common/` file paths listed.

No additional tool calls needed. The PreToolUse lock forces a text response before any tool use.

### Manual path (Codex / Gemini CLI / other)

If no `=== AI BRAIN ===` marker is present:

1. **Derive paths** — Set `PROJECT_NAME` and `BRAIN_ROOT` per Paths section.
2. **Verify Brain Root** — `ls "$BRAIN_ROOT"`. Missing → ask user for location.
3. **Read Tier 1** — Read `architecture_decisions.md` + `known_issues.md`. Missing project dir → create from `$BRAIN_ROOT/_example/` templates, notify user.
4. **Note Tier 2 paths** — Remember paths to `todo.md`, `journal.md`, `skill-experience.md`. Do not read yet.
5. **Note Tier 3 paths** — Remember paths to `_common/` files (excluding `SCHEMA.md`). Do not read yet.
6. **Respond to user** — Answer the user's message before any other tool use.

### Lazy rules (shared by both paths)

- **Project mapping** (`ls`, read key files) → defer until first Edit/Write on project files.
- **Tier 2/3 files** → read only when the current task needs them.
- **Constraints** — `architecture_decisions.md` = absolute truth. Project Brain wins over Common Brain on conflicts.

## Write-Back

### Event-Triggered Updates

Each Brain file is written by the Skill that produces the content, at the moment the event occurs:

| Brain File | Trigger | Owning Skill |
|---|---|---|
| `journal.md` | Code/config written | ai-brain |
| `known_issues.md` | Bug/workaround discovered | ai-brain |
| `architecture_decisions.md` | DDD phase confirmed | ddd-bdd-tdd |
| `todo.md` | BDD phase confirmed | ddd-bdd-tdd |
| `skill-experience.md` | Violation/fix recorded | prompt-engineer |
| `_common/` catalog | Conversation ending | conversation-logger |

### ai-brain Owned Files

- **journal.md** — One-line description of what was done. Write immediately after code/config changes.
- **known_issues.md** — Record bugs, workarounds, and pitfalls as discovered. Do not batch.

All write-back actions are **Auto + Notify** (load/metadata updates are silent). Proposing new Brain categories requires **Ask**.

## Skill Experience

`skill-experience.md` organizes cross-project experience by Skill name with stats and a chronological log.

### Format

```markdown
## <skill-name>
<!-- stats: violation=N | fix=N | skipped=N -->
- YYYY-MM-DD [tag] Description
```

Tags: `[violation]`, `[fix]`, `[skipped]`, `[dismissed]`.

### Update Rules

- **Violation** (user corrects): `violation += 1`. Log required.
- **Fix applied**: `fix += 1`. Log required.
- **Skipped** (user manually invokes a Skill that should have auto-triggered): `skipped += 1`. Log required.

## Rules

1. All Brain paths derive from `$BRAIN_ROOT`. Never hardcode absolute paths or usernames.
2. Never use Claude Code's memory system (`~/.claude/brain`, `~/.claude/projects/*/memory/`). It is a separate system.
3. Brain data lives only at `$BRAIN_ROOT`. Project files with overlapping names are not Brain data.
4. Never create `architecture_decisions.md` in the project root.
5. Never write to `conversation-patterns.md` or `prompt-violations.md` — owned by other Skills.
6. If Brain access fails, stop and ask the user. Do not fall back to alternative directories.
7. Aging: first conversation of each month, suggest archiving if `lastAccessed > 90 days` and `hitCount < 3`. Skill experience entries never age.
