---
name: prompt-engineer
description: >
  Diagnose and fix violations of system prompt rules or Skill instructions. Trigger this
  skill when: the user reports that AI did not follow a rule, the user corrects AI behavior
  that should have been governed by an existing Skill or system prompt, the user says
  "你怎麼又...", "I told you to...", "你沒有遵守", "rule violation", "skill not working",
  "觸發不準", "description 要改", or expresses frustration that AI ignored instructions.
  Also trigger when the user wants to improve, debug, or optimize any SKILL.md file or
  system prompt. Skip for: normal corrections unrelated to prompt/skill rules (e.g., factual
  errors, typos in code).
---

# Prompt Engineer

## Purpose

When AI behavior violates system prompt or Skill rules, diagnose the root cause and propose concrete fixes. This skill closes the feedback loop between the user's expectations and the AI's actual behavior.

## Violation Recording

When the user reports a rule violation, immediately capture:

```markdown
### Violation — YYYY-MM-DD
- **What happened:** <describe the AI behavior that violated the rule>
- **Expected behavior:** <what should have happened per the rule>
- **Rule location:** <Skill name + section, or system prompt section>
- **Exact rule text:** <quote the rule that was violated>
- **Conversation context:** <brief description of what triggered the violation>
```

Store violation records in the Common Brain. Path: see ai-brain Paths section. File: `$BRAIN_ROOT/_common/prompt-violations.md`.

If the file does not exist, create it with header:

```markdown
# Prompt & Skill Violation Log

> Tracked by prompt-engineer skill.
> Each entry includes root cause analysis and proposed fix.
```

## Root Cause Analysis

After recording the violation, analyze WHY it happened. There are four common root causes:

### 1. Skill Not Loaded

The relevant Skill was not triggered because the `description` did not match the conversation context.

**Diagnosis:** Check if the Skill's description keywords overlap with the user's input. If not, the description needs broader trigger terms.

**Fix pattern:** Expand the description with additional trigger phrases or synonyms. Example: if the user said "寫程式" but the description only has "writing code", add the Chinese trigger keyword.

### 2. Ambiguous Rule

The rule was loaded but its wording allowed the AI to interpret it differently than intended.

**Diagnosis:** Read the exact rule text. Is there room for misinterpretation? Could the AI reasonably think it was following the rule while doing the wrong thing?

**Fix pattern:** Make the rule more specific. Add concrete examples of correct vs incorrect behavior. Convert vague guidance into explicit if-then rules.

### 3. Rule Conflict

Two rules in different Skills (or within the same Skill) gave contradictory guidance, and the AI chose the wrong one.

**Diagnosis:** Identify both conflicting rules. Check if the system prompt's Conflict Resolution section covers this case.

**Fix pattern:** Add an explicit priority rule to the system prompt's Conflict Resolution section, or restructure the conflicting rules so they don't overlap.

### 4. AI Tendency Override

The rule is clear and loaded, but the AI's default behavior is strong enough to override it. Common examples: AI tends to be verbose despite "no performance art" rules, AI tends to jump into code despite "discuss first" rules.

**Diagnosis:** The rule exists and is unambiguous, but the AI keeps violating it across multiple conversations.

**Fix pattern:** Escalate the rule's emphasis. Add to a "NEVER do these" list. Use stronger language: "CRITICAL", "MANDATORY". Add the negative example explicitly: "Do NOT do X. Instead, do Y." Consider moving the rule to the system prompt (higher priority than Skills).

## Proposing Fixes

After root cause analysis, present the fix as a concrete diff:

```markdown
## Proposed Fix

**File:** `skills/response-protocol/SKILL.md`
**Section:** Action Authority Matrix
**Root cause:** Type 4 — AI Tendency Override
**Change:**

BEFORE:
> Code is only written when the user explicitly requests it.

AFTER:
> Code is only written when the user explicitly requests it.
> NEVER begin writing code when the user asked a question. Answer the question
> first, even if the answer seems obvious and you want to "save time" by coding
> immediately.
```

Wait for user confirmation before applying any fix.

## Integration with Other Skills

### → conversation-logger

When a violation is recorded, also notify `conversation-logger` to log it as a "Correction" pattern. This ensures the violation feeds into the broader pattern analysis.

### → skill-extractor

If the same violation type recurs 3+ times across different conversations (check `prompt-violations.md` history), flag it in the next `skill-extractor` analysis as a systemic issue that may need a new Skill or a structural redesign rather than a patch.

### → ai-brain

After a fix is confirmed and applied, write to `_common/skill-experience.md` under the relevant Skill's section:
- Add a `[violation]` log entry describing the issue.
- Add a `[fix]` log entry describing the applied fix.
- Update the stats counter: `violation += 1`.
- If a Skill accumulates 3+ violations without a successful fix, flag it as having a systemic problem and recommend a structural review rather than a patch.

## Proactive Mode

Beyond reacting to violations, this skill can also be triggered proactively:

- **User says "review my skills"** — Read all active SKILL.md files, check for common anti-patterns (vague rules, missing NEVER clauses, overlapping descriptions), and suggest improvements.
- **User says "why did you do X"** — Trace back through loaded Skills and system prompt to explain which rules influenced the behavior, even if no violation occurred. This helps the user understand the AI's decision process.

## Self-Detection Mode

When AI detects that it is about to violate or has just violated a rule — even before the user notices — it should **proactively inform the user and offer to trigger the evolution loop**.

### Detection Triggers

- AI catches itself about to skip a step defined in a Skill (e.g., about to write code without discussing first).
- AI realizes mid-response that it is not following a loaded rule (e.g., responding in English when `warm-persona` says Traditional Chinese).
- AI notices a Skill should have triggered but didn't (e.g., user is clearly doing a new feature but `ddd-bdd-tdd` was not loaded).
- AI encounters a situation where existing rules are ambiguous or contradictory.
- AI wrote code/config but is about to respond without updating journal.md.

### Response Format

When a detection trigger fires, append this to the current response:

```
---
⚠️ 我發現 [具體描述偵測到的問題]。
這可能是 [Skill 名稱] 的規則需要調整。
要不要我記錄這個問題並提出修正建議？
```

### User Responses

- **User says yes** — Execute the full violation recording + root cause analysis + proposed fix flow.
- **User says no / ignores** — Do nothing. Do NOT ask again for the same issue in the same conversation.
- **User says "以後不要問這個"** — Log to `skill-experience.md` as a `[dismissed]` entry so this specific pattern is not flagged again.

### Limits

- Maximum 2 self-detection prompts per conversation. Do not overwhelm the user.
- Only prompt for issues with real impact. Do not flag trivial formatting preferences or cosmetic inconsistencies.
- When in doubt, log to `conversation-patterns.md` silently and let `skill-extractor` catch it later, rather than interrupting the user.

## Key Principle

Every fix must be **minimal and targeted**. Do not rewrite entire Skills in response to a single violation. Change the least amount of text needed to prevent the specific violation from recurring. Broader refactoring should be proposed separately and requires explicit user approval.
