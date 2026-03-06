---
name: skill-extractor
description: >
  Analyze accumulated conversation patterns and extract Skill candidates. Reads the
  conversation-patterns.md log, clusters similar entries, evaluates frequency and value,
  and generates draft SKILL.md files for user review. Trigger this skill when: the user
  says "分析模式", "analyze patterns", "extract skills", "what skills should I make",
  "該做什麼 Skill", or requests a periodic review of accumulated patterns. Also trigger
  when conversation-patterns.md has 15+ unanalyzed entries. Skip for: creating a specific
  known skill (create SKILL.md manually instead), or general conversation.
---

# Skill Extractor

## Purpose

Read the accumulated conversation pattern log, identify recurring themes that would benefit from being formalized as Skills, and generate draft SKILL.md files for user approval.

## Input

Path: see ai-brain Paths section. File: `$AI_BRAIN_ROOT/_common/conversation-patterns.md`.

If this file does not exist or is empty, inform the user: "No patterns accumulated yet. The conversation-logger skill needs to run across several conversations first. I recommend waiting until 15+ entries are logged."

## Analysis Process

### Step 1 — Read and Parse

Read `conversation-patterns.md`. Parse each entry by date, topic, and pattern type. Count total entries and identify the date range covered.

### Step 2 — Cluster Similar Patterns

Group entries by semantic similarity. Look for:

- **Same instruction repeated** across different dates (e.g., user keeps saying "use English for commits")
- **Same correction** applied multiple times (e.g., user keeps correcting AI to not add Co-Author)
- **Same preference** expressed in different contexts (e.g., always chooses Cloudflare over alternatives)
- **Same technical pattern** applied across projects (e.g., AES-256-GCM encryption pattern)

Name each cluster with a descriptive label.

### Step 3 — Evaluate Each Cluster

For each cluster, answer three questions:

| Question                                       | Threshold                       |
| ---------------------------------------------- | ------------------------------- |
| How many times does this pattern appear?       | Must be 3+ entries to qualify   |
| Is this already covered by an existing Skill?  | If yes, skip or suggest update  |
| Would formalizing this actually save time?      | Subjective — apply judgment     |

Discard clusters that fail any threshold.

### Step 4 — Generate Skill Drafts

For each qualifying cluster, generate a draft SKILL.md with:

- `name` — derived from the cluster label
- `description` — derived from the pattern content, written to maximize trigger accuracy
- Body — rules and guidelines extracted from the accumulated patterns

### Step 5 — Present to User

Present results as a structured report:

```markdown
## Skill Extraction Report — YYYY-MM-DD
**Patterns analyzed:** [total count]
**Date range:** [earliest] to [latest]
**Clusters found:** [count]
**Qualified candidates:** [count]

### Candidate 1: `<skill-name>`
- **Evidence:** [N] entries across [M] conversations
- **Key patterns:**
  - Pattern summary 1
  - Pattern summary 2
- **Recommendation:** [High/Medium/Low] value
- **Draft:** [included below or in separate file]

### Candidate 2: (already covered)
- **Evidence:** [N] entries
- **Covered by:** `<existing-skill-name>`
- **Recommendation:** Skip / Update existing skill with [specific addition]

### Candidate 3: ...
```

## Post-Analysis Actions

After presenting the report, ask the user which candidates to proceed with. For approved candidates:

1. Finalize the SKILL.md draft based on user feedback.
2. Save to the appropriate skills directory.
3. Mark analyzed entries in `conversation-patterns.md` by appending `[Analyzed: YYYY-MM-DD]` to the entry header line, so they are not re-analyzed in the next run.

For rejected candidates, do nothing — the patterns remain in the log and may accumulate more evidence for future analysis.

## Interaction with Existing Skills

When a cluster overlaps with an existing Skill, do NOT create a new Skill. Instead, propose a specific amendment to the existing Skill. Present the amendment as a diff or a clear "add this section" instruction.

## Limits

- Run at most once per week (to allow patterns to accumulate).
- Generate at most 3 Skill candidates per run (focus on highest value).
- Never auto-create Skills without user approval — always present drafts for review first.
