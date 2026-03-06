---
name: ai-brain
description: >
  Project knowledge base (Git-versioned Markdown).
  Manages project-level and cross-project knowledge.
  This skill is ALWAYS active — it loads in every conversation to ensure context continuity.
  Owns journal.md and known_issues.md write-back.
  The user mentions "AI-Brain", "記憶", "大腦" to interact with it explicitly, but it runs in the background even without explicit mention.
  Unrelated to Claude's built-in memory (~/.claude/).
hooks:
  Stop:
    - matcher: "*"
      hooks:
        - type: prompt
          prompt: >
            Review the assistant's last message and tool calls to determine if code or config was written/modified (Edit, Write, or NotebookEdit tool calls on project files).
            "Project files" = files under the current working directory.
            Files under the ai-brain directory (AI-Brain data) are NOT project files — ignore them.

            Rules:
            1. If Edit/Write tool call targeted journal.md, respond {"ok": true}
            2. If no code/config was written (discussion, Q&A, clarification, planning), respond {"ok": true}
            3. If code/config was written, respond {"ok": false, "reason": "You wrote code/config but did not update journal.md. Add a one-line entry to $AI_BRAIN_ROOT/$PROJECT_NAME/journal.md describing what was done."}
---

# AI-Brain Protocol

## Paths

Derive all paths from `$PWD`.
Never hardcode absolute paths or usernames.

```bash
PROJECT_NAME=$(basename "$PWD")
AI_BRAIN_ROOT="$(dirname "$PWD")/ai-brain"
```

| Path               | Location                             |
| ------------------ | ------------------------------------ |
| Project AI-Brain      | `$AI_BRAIN_ROOT/$PROJECT_NAME/`         |
| Common AI-Brain       | `$AI_BRAIN_ROOT/_common/`               |
| Project Template   | `$AI_BRAIN_ROOT/_example/`              |

## AI-Brain Structure

### Project AI-Brain

| File                        | Purpose                                           |
| --------------------------- | ------------------------------------------------- |
| `architecture_decisions.md` | Hard constraints, tech stack, domain model         |
| `todo.md`                   | Active tasks, future plans, backlog                |
| `known_issues.md`           | Bugs, technical debt, workarounds                  |
| `journal.md`                | Daily logs, progress notes                         |

New projects: copy templates from `$AI_BRAIN_ROOT/_example/`.

### Common AI-Brain

| File | Purpose |
| --- | --- |
| `preferences.md` | Personal preferences: naming, formatting, tool choices |
| `troubleshooting.md` | Cross-project solutions to recurring problems |
| `toolchain.md` | CLI, IDE, CI/CD, deployment notes |
| `skill-experience.md` | Skill tuning and pitfall log |

Skill-owned files: `conversation-patterns.md` (conversation-logger), `prompt-violations.md` (prompt-engineer).

## Loading Procedure

Execute on the first message of every conversation. Skip only if user says "skip AI-Brain".

### Hook path (Claude Code)

If `=== AI BRAIN ===` marker is present in context, the SessionStart hook has injected an **AI-Brain Map** — file paths, descriptions, and entry counts (~20 lines).
The AI-Brain Map includes an `AI_BRAIN_ROOT=<resolved path>` line — use this exact path for all file reads.
No full file contents are in context yet.

**Steps:**

1. **Read user message** — Determine which AI-Brain files are relevant to the task.
   - `architecture_decisions.md` is ALWAYS relevant for code/design tasks.
   - `known_issues.md` is ALWAYS relevant for code/debug tasks.
   - Other files: match by task type (planning → `todo.md`, resuming → `journal.md`, etc.)
2. **Check entry count** — Sum entries of all relevant files (from the AI-Brain Map).
   - **< 15 total entries →** Read the relevant files directly using the resolved path from the AI-Brain Map (e.g., `Read("<AI_BRAIN_ROOT>/project/file.md")`).
   - **≥ 15 total entries →** Launch ONE Explore sub-agent to read and distill. **Pass the resolved AI_BRAIN_ROOT path from the AI-Brain Map — never let the sub-agent derive or guess paths:**
     ```
     Explore agent prompt template:
     "Read these AI-Brain files: [list FULL resolved paths from AI-Brain Map].
     For the user's task: '[first message summary]',
     extract ONLY the entries relevant to this task. Return a concise summary organized by file.
     Skip entries that are clearly unrelated.
     IMPORTANT: Use ONLY the file paths provided above. Do NOT guess or derive AI-Brain paths."
     ```
3. **Respond to user** — The PreToolUse lock forces a text response before any tool use. Answer the user's question or acknowledge their task.

**Caching:** Do not re-read AI-Brain files already loaded in the same conversation.
Re-run only on topic switch.

### Manual path (Codex / Gemini CLI / other)

If no `=== AI BRAIN ===` marker is present:

1. **Derive paths** — Set `PROJECT_NAME` and `AI_BRAIN_ROOT` per Paths section.
2. **Verify AI-Brain Root** — `ls "$AI_BRAIN_ROOT"`. Missing → ask user for location.
3. **List project AI-Brain** — `ls "$AI_BRAIN_ROOT/$PROJECT_NAME/"`. Missing → create from `$AI_BRAIN_ROOT/_example/` templates, notify user.
4. **Read by relevance** — Based on user message, read the relevant AI-Brain files:
   - Small files (≤ 40 entries) → read fully.
   - Large files (> 40 entries) → read only headers/titles, then read specific sections as needed.
5. **Respond to user** — Answer the user's message before any other tool use.

### Lazy rules (shared by both paths)

- **Project mapping** (`ls`, read key files) → defer until first Edit/Write on project files.
- **Non-selected files** → read only when the current task needs them.
- **Constraints** — `architecture_decisions.md` = absolute truth. Project AI-Brain wins over Common AI-Brain on conflicts.

## Write-Back

### Event-Triggered Updates

Each AI-Brain file is written by the Skill that produces the content, at the moment the event occurs:

| AI-Brain File | Trigger | Owning Skill |
|---|---|---|
| `journal.md` | Code/config written | ai-brain |
| `known_issues.md` | Bug/workaround discovered | ai-brain |
| `architecture_decisions.md` | DDD phase confirmed | ddd-bdd-tdd |
| `todo.md` | BDD phase confirmed | ddd-bdd-tdd |
| `skill-experience.md` | Violation/fix recorded | prompt-engineer |
| `_common/` catalog | Conversation ending | conversation-logger |

### ai-brain Owned Files

- **journal.md** — One-line description of what was done.
  Write immediately after code/config changes.
- **known_issues.md** — Record bugs, workarounds, and pitfalls as discovered.
  Do not batch.

All write-back actions are **Auto + Notify** (load/metadata updates are silent).
Proposing new AI-Brain categories requires **Ask**.

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

1. All AI-Brain paths derive from `$AI_BRAIN_ROOT`.
   Never hardcode absolute paths or usernames.
2. Never use Claude Code's memory system (`~/.claude/brain`, `~/.claude/projects/*/memory/`).
   It is a separate system.
3. AI-Brain data lives only at `$AI_BRAIN_ROOT`.
   Project files with overlapping names are not AI-Brain data.
4. Never create `architecture_decisions.md` in the project root.
5. Never write to `conversation-patterns.md` or `prompt-violations.md` — owned by other Skills.
6. If AI-Brain access fails, stop and ask the user.
   Do not fall back to alternative directories.
7. Aging: first conversation of each month, suggest archiving if `lastAccessed > 90 days` and `hitCount < 3`.
   Skill experience entries never age.
