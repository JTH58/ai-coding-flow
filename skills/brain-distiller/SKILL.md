---
name: brain-distiller
description: >
  AI-Brain maintenance-only distillation skill.
  Distills bloated AI-Brain files by scanning, clustering, summarizing, and archiving stale entries while preserving full history.
  Trigger only when the user explicitly starts an AI-Brain maintenance session with phrases like "distill", "蒸餾", "整理 AI-Brain", "AI-Brain maintenance", "clean up brain", or "/distill".
  During ordinary coding, debugging, refactoring, planning, or routine AI-Brain read/write work, this skill must not run distillation.
  If bloat is noticed during normal work, only suggest opening a separate maintenance session.
---

# AI-Brain Distiller

## Purpose

Reduce active AI-Brain noise while preserving complete historical traceability. Distillation compacts the files used during normal AI-Brain loading, but it never destroys original information.

This skill separates:
- **Active AI-Brain** — concise files used during normal work.
- **Archived history** — full pre-distillation files stored under `_archive/`, excluded from normal AI-Brain loading and read only on explicit request.
- **Distillation records** — an execution record for every maintenance run, with durable on-disk logs for every applied run.

The goal is not to make AI-Brain shorter at all costs. The goal is to keep current working context precise while preserving old knowledge for audit, recovery, and future investigation.

## When to Trigger

| Trigger | Action |
|---------|--------|
| User explicitly starts maintenance (`/distill`, "整理 AI-Brain", "AI-Brain maintenance", etc.) | Run the maintenance flow |
| User asks for a specific file (`/distill journal.md`) | Run maintenance only for that file |
| User asks for project/common scope | Scan and propose candidates for that scope |
| AI-Brain bloat is noticed during normal work | Do not run. Only suggest opening a separate maintenance session |

## Non-Trigger Rules

This skill must never perform distillation inside an ordinary coding, debugging, refactoring, planning, or feature-development task.

During normal work:
- Do not scan all AI-Brain files unless directly relevant to the user request.
- Do not summarize, merge, archive, or rewrite AI-Brain files.
- Do not interrupt the user's task with a maintenance workflow.
- If a file appears bloated, mention maintenance briefly at the end: "AI-Brain maintenance may be useful; open a separate `/distill` session when ready."

## Scope

Distillation operates only under `$AI_BRAIN_ROOT`.

Project AI-Brain candidates:
- `architecture_decisions.md`
- `known_issues.md`
- `todo.md`
- `journal.md`

Common AI-Brain candidates:
- `_common/preferences.md`
- `_common/troubleshooting.md`
- `_common/toolchain.md`
- `_common/conversation-patterns.md`
- `_common/skill-experience.md`
- `_common/prompt-violations.md`

Never touch project source files. Never touch files outside `$AI_BRAIN_ROOT`.

## Maintenance Flow

### Step 1 — Read

Read the requested AI-Brain scope:
- If the user names a file, read that file.
- If the user names a project, read that project's AI-Brain files.
- If the user says `/distill` without a target, inspect project + common AI-Brain candidates and list files that need maintenance.

For each candidate file, identify:
- Total line count
- Entry count
- Date range, if available
- Existing summary/archive sections
- Active vs. resolved/completed/superseded content
- Last applied distillation for this file from `_archive/distillation-log.md`, if present

### Step 2 — Select Candidates

Propose files for distillation when they show clear maintenance signals:
- More than 40 meaningful entries
- More than 300 lines of accumulated notes
- Repeated or near-duplicate entries
- Resolved/completed content older than the file policy threshold
- Superseded decisions mixed into current decision sections
- Repeated headings, placeholder clutter, or structural drift

If no file needs maintenance, report that no distillation is needed and stop.

### Step 3 — Dry-Run Plan

Dry-run is mandatory. Before writing anything, present a plan for one file at a time:

```
## Distillation Plan: <filename>

**Scope:** project/common
**Last applied run:** <run id or none>
**Before:** N entries / L lines
**Proposed after:** M entries / K lines
**Archive file:** _archive/<filename>_<run-id>.md
**Policy:** <file-specific policy>

### Keep Verbatim
- <active/current item>

### Summarize
- <old detailed entries> -> <proposed summary>

### Move Out of Active Context
- <stale/resolved/completed item> -> archived in full pre-distillation backup

### Risks
- <what context might become harder to see during normal AI-Brain loading>

Apply this distillation? (yes/no)
```

Do not modify any file before explicit user approval.

### Step 4 — Archive Current State

After approval and before modifying the active file, create an immutable archive of the full current file.

Use a timestamped run id:

```bash
RUN_ID="$(date +%Y%m%d-%H%M%S)"
```

Project AI-Brain archive:

```bash
mkdir -p "$AI_BRAIN_ROOT/$PROJECT_NAME/_archive"
cp "$AI_BRAIN_ROOT/$PROJECT_NAME/<file>.md" \
  "$AI_BRAIN_ROOT/$PROJECT_NAME/_archive/<file>_$RUN_ID.md"
```

Common AI-Brain archive:

```bash
mkdir -p "$AI_BRAIN_ROOT/_common/_archive"
cp "$AI_BRAIN_ROOT/_common/<file>.md" \
  "$AI_BRAIN_ROOT/_common/_archive/<file>_$RUN_ID.md"
```

Archive rules:
- Archives are full pre-distillation snapshots, not partial diffs.
- Archives are immutable. Never edit archived files after creation.
- Never overwrite archives. Use timestamped run ids, not date-only names.
- Archives are excluded from normal AI-Brain loading.
- Read archives only when the user explicitly asks to inspect, restore, compare, or audit old history.

### Step 5 — Apply Incremental Distillation

Distillation must be incremental:
- Read `_archive/distillation-log.md` before applying changes.
- Identify the last applied run for the target file.
- Do not repeatedly compress content that was already summarized.
- Only summarize or move newly stale content that crossed the policy threshold since the last run.
- If a previous summary must be updated with newly stale entries, archive first and record the reason in the log.

Preservation rules:
- Preserve active/unresolved/current items verbatim.
- Preserve decision history and causal context.
- Summarize process history, not durable knowledge.
- Do not turn useful technical knowledge into vague summaries.
- Prefer compact structured summaries over deletion.

### Step 6 — Write Distillation Log

Every brain-distiller execution must produce a record. Dry-run-only executions include the record in the response. Every applied distillation must also append a durable record to `_archive/distillation-log.md` in the same scope as the modified file.

Project log:

```text
$AI_BRAIN_ROOT/$PROJECT_NAME/_archive/distillation-log.md
```

Common log:

```text
$AI_BRAIN_ROOT/_common/_archive/distillation-log.md
```

Log format:

```markdown
## YYYY-MM-DD HH:MM:SS — <file>

- **Run ID:** YYYYMMDD-HHMMSS
- **Mode:** applied
- **Scope:** project/common
- **Source file:** <file>
- **Archive file:** _archive/<file>_<run-id>.md
- **Before:** N entries / L lines
- **After:** M entries / K lines
- **Policy:** <file-specific policy>
- **User approval:** explicit yes
- **Summary of changes:**
  - <kept/summarized/archived outcome>
- **Risks / follow-up:**
  - <optional>
```

Dry-run-only sessions must include the proposed log record in the response, but must not write it unless the user explicitly asks to record the dry run.

### Step 7 — Present Result

After applying changes, report:
- Archive path
- Distillation log path
- Before/after counts
- What was kept verbatim
- What was summarized
- What moved out of active context
- Any residual risk or follow-up

## File Policy Matrix

Apply file-specific policies. Do not use a one-size-fits-all summary rule.

| File | Active Context Policy | Distillation Policy |
|------|-----------------------|---------------------|
| `journal.md` | Keep the most recent 30 days detailed | Convert older detailed logs into monthly summaries. Full original stays in archive |
| `known_issues.md` | Keep active/unresolved issues verbatim | Summarize or move resolved issues older than 60 days out of active context |
| `todo.md` | Keep open items verbatim | Move completed items older than 30 days into a compact completed summary |
| `architecture_decisions.md` | Keep current ADRs and decision history | Never delete ADRs. Mark superseded ADRs or move them to a `Superseded` section only when clearly obsolete |
| `preferences.md` | Keep current preferences, priorities, and exceptions | Merge duplicates by category while preserving precedence and exceptions |
| `troubleshooting.md` | Keep reusable fixes and exact commands | Group by technology/problem, merge duplicate fixes, preserve actionable steps and affected versions |
| `toolchain.md` | Keep current tool behavior, version constraints, and setup notes | Group by tool, merge version-specific notes only when the applicability remains clear |
| `conversation-patterns.md` | Keep recent unanalyzed patterns | Summarize patterns already extracted into Skills or stable preferences |
| `skill-experience.md` | Keep recent effective lessons per Skill | Keep the most useful recent entries per Skill; summarize old violations into trends |
| `prompt-violations.md` | Keep open/systemic violations verbatim | Group resolved violations by root cause after the fix is applied and stable |

## Repeated Distillation

When distillation is run again:

1. Read the active file.
2. Read `_archive/distillation-log.md`.
3. Find the last applied run for the target file.
4. Identify only new content that crossed the policy threshold since that run.
5. Do not re-summarize already summarized content.
6. If an existing summary must be amended, archive first and explain why.
7. Append a new log entry after applying changes.

If no new content crossed the threshold, report:

```text
No distillation needed.
Last applied run: <run id>
No new entries crossed the maintenance threshold.
```

## Scope Selection

When user runs `/distill` without specifying a file:

1. Check project + common AI-Brain candidates.
2. List files that exceed maintenance thresholds.
3. If none exceed thresholds, report that all AI-Brain files are healthy enough and stop.
4. If multiple files need work, recommend the safest order:
   - `journal.md`
   - `todo.md`
   - `known_issues.md`
   - common logs (`conversation-patterns.md`, `skill-experience.md`, `prompt-violations.md`)
   - reusable knowledge files (`troubleshooting.md`, `toolchain.md`, `preferences.md`)
   - `architecture_decisions.md` last, only when clearly needed
5. Process and confirm one file at a time.

## Safety Rules

1. **Maintenance-only** — Never distill during ordinary project work.
2. **Dry-run first** — Always present a plan before writing.
3. **User approval required** — Wait for explicit approval before modifying any file.
4. **Archive before modify** — Always create a timestamped full-file archive before editing.
5. **Immutable archives** — Never overwrite or edit archive files.
6. **Log every applied run** — Append to `_archive/distillation-log.md`.
7. **Preserve active items** — Never summarize active, unresolved, current, or still-actionable entries.
8. **Never delete ADRs** — Preserve decision history. Mark or move superseded decisions only when clearly obsolete.
9. **One file at a time** — Even when distilling "all", plan, approve, apply, archive, and log per file.
10. **AI-Brain paths only** — Operate only under `$AI_BRAIN_ROOT`.

## Anti-Patterns

- Rewriting old knowledge because it "looks messy" without preserving the full original.
- Compressing technical lessons until commands, versions, or constraints are lost.
- Re-running summaries over summaries until meaning degrades.
- Treating `journal.md` as the only file that can be distilled.
- Using date-only archive names that can overwrite earlier runs.
- Reading `_archive/` during normal AI-Brain loading.
