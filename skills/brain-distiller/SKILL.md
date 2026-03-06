---
name: brain-distiller
description: >
  Distill bloated AI-Brain files by clustering, merging, and archiving stale entries.
  Trigger when: user says "distill", "蒸餾", "整理 AI-Brain", "clean up brain",
  "/distill", or when the AI-Brain Map health check shows ⚠️ warnings (> 40 entries).
  Also suggest proactively when a AI-Brain file exceeds 40 entries during normal work.
  Skip for: routine AI-Brain read/write, small files, general conversation.
---

# AI-Brain Distiller

## Purpose

Reduce AI-Brain file bloat while preserving essential knowledge. Keeps AI-Brain files concise so that AI-Brain Map loading stays efficient (~20 lines) and selective reading stays fast.

## When to Trigger

| Trigger | Action |
|---------|--------|
| User explicitly requests (`/distill`, "整理 AI-Brain", etc.) | Run full distillation flow |
| AI-Brain Map health ⚠️ warning (> 40 entries) | Suggest: "⚠️ [file] has N entries. Run `/distill` to clean up?" |
| During normal work, a file crosses 40 entries | Same suggestion as above |

**NEVER** auto-execute distillation. Always require user confirmation before modifying AI-Brain files.

## Distillation Flow (5 Steps)

### Step 1 — Read

Read the target AI-Brain file(s) fully. Identify:
- Total entry count
- Date range (oldest → newest)
- Category clusters (by topic, status, or time period)

### Step 2 — Cluster

Group entries by semantic similarity:

| File | Clustering Strategy |
|------|-------------------|
| `troubleshooting.md` | By topic/technology (e.g., Docker, Git, TypeScript) |
| `journal.md` | By time period (keep last 30 days detailed, older → monthly summary) |
| `known_issues.md` | By status: active vs. resolved. Resolved > 60 days → archive |
| `architecture_decisions.md` | By relevance: current vs. superseded ADRs |
| `todo.md` | By status: completed items > 30 days → archive |
| `preferences.md` | By category, merge duplicates |
| `toolchain.md` | By tool, merge version-specific entries |
| `skill-experience.md` | Keep last 10 entries per skill, archive older |

### Step 3 — Merge

For each cluster:
- **Merge** duplicate or near-duplicate entries into one consolidated entry
- **Summarize** resolved/completed items into a single line (e.g., "5 Docker DNS issues resolved — use `host.docker.internal`")
- **Preserve** active/unresolved items verbatim
- **Keep** all ADR entries in `architecture_decisions.md` (never merge ADRs — only archive superseded ones)

### Step 4 — Archive

Before modifying any file:

```bash
# Create archive directory
mkdir -p "$AI_BRAIN_ROOT/$PROJECT_NAME/_archive"
# or for Common AI-Brain:
mkdir -p "$AI_BRAIN_ROOT/_common/_archive"

# Backup with timestamp
cp "$AI_BRAIN_ROOT/$PROJECT_NAME/<file>.md" \
   "$AI_BRAIN_ROOT/$PROJECT_NAME/_archive/<file>_$(date +%Y%m%d).md"
```

- Archives are **read-only backups** — never modified after creation.
- One backup per file per day (overwrite if same day).
- Archives are NOT loaded by brain-loader.sh (excluded by path).

### Step 5 — Present Diff

Show the user a before/after comparison:

```
## Distillation Result: <filename>

**Before:** N entries | **After:** M entries | **Archived:** K entries

### Removed/Merged:
- [entry 1] — merged into [consolidated entry]
- [entry 2] — archived (resolved > 60 days)

### Kept:
- [active entry 1]
- [active entry 2]

### New Consolidated Entries:
- [merged summary]

Apply these changes? (yes/no)
```

**NEVER** write changes without explicit user approval on the diff.

## Scope Selection

When user runs `/distill` without specifying a file:

1. Check all AI-Brain files (project + common) for entry counts
2. List files that exceed 40 entries
3. If none exceed 40: "All AI-Brain files are healthy (< 40 entries each). No distillation needed."
4. If multiple exceed 40: present the list, ask user which to distill (or "all")

## Rules

1. **Archive before modify** — Always create `_archive/` backup before any changes.
2. **User approval required** — Present diff, wait for explicit "yes" before writing.
3. **Never delete ADRs** — Architecture decisions are historical records. Superseded ADRs get an `[ARCHIVED]` prefix but stay in the file. Only move to `_archive/` if explicitly requested.
4. **Preserve active items** — Never merge, summarize, or archive entries that are still active/unresolved.
5. **One file at a time** — Process and confirm each file individually, even when distilling "all".
6. **AI-Brain paths only** — Only operates on files under `$AI_BRAIN_ROOT`. Never touch project files.
