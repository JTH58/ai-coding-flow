---
name: code-verification
description: >
  Code quality verification loop and response ending stamps. Trigger this skill whenever
  Claude writes, modifies, or reviews code. This includes: implementing features, fixing
  bugs, refactoring, writing tests, code review, or any task that produces code output.
  Also trigger when the user asks about build status, test results, or verification.
  Skip for: pure discussion, architecture planning (before code), or documentation-only tasks.
---

# Code Verification

## Verification Loop

Every piece of code goes through this loop before the user sees it:

```
WRITE → TEST → [FAIL? → FIX → RE-TEST] → SUCCESS → PRESENT
```

| Step                   | Rule                                                                          |
| ---------------------- | ----------------------------------------------------------------------------- |
| **Test Immediately**   | Run build/test command after writing code.                                    |
| **Self-Correct**       | If build/test fails, fix and re-run silently. Never show intermediate errors. |
| **TDD Integration**    | When `ddd-bdd-tdd` skill is active, run BDD-derived tests first.             |
| **Codebase Check**     | Before writing new code, find 2+ similar patterns in the project. Match their style. |
| **Present on Success** | Only show code after verification passes.                                    |

> **Silent self-correction applies ONLY to build/test failures.** All other issues (missing files, access errors, unexpected states) must be reported to the user.

### Escalation Protocol (3-Attempt Rule)

If the same problem fails **3 consecutive attempts** (build error, test failure, or runtime bug):

1. **STOP** — Do not attempt a 4th fix using the same approach.
2. **Document** — Tell the user what was tried and why each attempt failed.
3. **Research** — Search the codebase for similar solved problems. Check documentation.
4. **Reframe** — Is the test correct? Is the architecture sound? Are the assumptions valid?
5. **Pivot** — Propose a fundamentally different approach before proceeding.

> "Same problem" = same error message or same failing test. Changing one variable and retrying counts as the same attempt.

## AI-Brain Integration

If code or config was written, update journal.md before presenting results (per ai-brain Write-Back rules).

## Response Ending Stamps

For code implementation/review tasks, append one verification-phase stamp from the table below.

| Scenario                      | Stamp                                         |
| ----------------------------- | --------------------------------------------- |
| DDD Phase complete            | `📌 DDD Complete — Awaiting Confirmation`     |
| BDD Phase complete            | `📌 BDD Complete — Awaiting Confirmation`     |
| Code with TDD                 | `✅ Tests: [X/X] \| Build: [Command]`         |
| Code without TDD              | `✅ Build Verified: [Command]`                |
| Discussion / Analysis only    | `⚠️ Verification Skipped: [Reason]`          |

When both `ddd-bdd-tdd` and `code-verification` are active, the code phase stamp takes precedence over planning phase stamps.

## Code on Demand Reminder

This skill governs verification, not authorization. Code is only written when the user explicitly requests it (per `response-protocol` Action Authority). Short illustrative snippets (< 10 lines) for explanation purposes are always allowed.

Short illustrative snippets (< 10 lines) are explanation-only and do not require build/test execution or verification stamps unless the user asks to verify or execute them.
