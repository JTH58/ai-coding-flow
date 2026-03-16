---
name: code-verification
description: >
  Code quality verification loop and response ending stamps.
  Trigger this skill whenever Claude writes, modifies, or reviews code.
  This includes: implementing features, fixing bugs, refactoring, writing tests, code review, or any task that produces code output.
  Also trigger when the user asks about build status, test results, or verification.
  Skip for: pure discussion, architecture planning (before code), or documentation-only tasks.
---

# Code Verification

## Verification Loop

Every piece of code goes through this loop before the user sees it:

``` 
WRITE → TEST → CROSS-CHECK → REVIEW → [issues? → FIX → RE-TEST → REVIEW] → SUCCESS → PRESENT
```

| Step                   | Rule                                                                          |
| ---------------------- | ----------------------------------------------------------------------------- |
| **Test Immediately**   | Run build/test command after writing code.                                    |
| **Self-Correct**       | If build/test fails, fix and re-run silently. Never show intermediate errors. |
| **TDD Integration**    | When `ddd-bdd-tdd` skill is active, run BDD-derived tests first.             |
| **Codebase Check**     | Before writing new code, find 2+ similar patterns in the project. Match their style. |
| **Cross-Check**        | After tests pass, run cross-module review (see below). Fix issues before presenting. |
| **Review Gate**        | After cross-check passes, run a review pass for code/config changes. Present only after review is resolved. |
| **Present on Success** | Only show code after verification, cross-check, AND review pass.              |

> **Silent self-correction applies ONLY to build/test failures.** All other issues (missing files, access errors, unexpected states) must be reported to the user.

### Cross-Module Review (Cross-Check)

After tests pass, verify the change doesn't break anything beyond the modified files. **Review includes fixing** — don't just report issues, fix them silently and re-test.

| Check               | Action                                                                        |
| -------------------- | ----------------------------------------------------------------------------- |
| **Impact Scan**      | Grep all references to changed symbols (functions, variables, types, rule names). Verify each call site is still correct. |
| **Caller Verification** | If a function signature or interface changed, confirm every caller has been updated. |
| **Rule Coherence**   | If adding/modifying a rule or instruction, scan other Skills and CLAUDE.md for contradictions. |
| **Deletion Safety**  | If code or config was removed, confirm no remaining references or imports.     |
| **Sync Check**       | If the project has parallel representations (e.g., AGENTS.md ↔ skills/, types ↔ runtime), verify they are in sync. |

**Scope Gate — only trigger Cross-Check when:**
- Function/API signature changed
- Rules or instructions added/modified
- Code or files deleted
- Structural changes across modules

Skip for: single-file bug fixes, typo corrections, style-only changes.

### Async Review Sub-Agent

After local verification passes, run a review pass for any task that **changed code or config files**.

**Preferred mode — true async sub-agent**
- If the runtime supports a background / asynchronous sub-agent, launch exactly one review sub-agent for the current diff.
- Immediately tell the user: `Review sub-agent 已啟動，主程序等待審查結果。`
- Then wait. Do **not** present the final completion message or verification stamp until the review result is back.
- Scope the review to changed files, directly affected callers, regression risk, and missing tests.
- Review goal: find bugs, behavioral regressions, unsafe assumptions, and test gaps. Ignore minor style nits.

**Fallback mode — synchronous review**
- If no true async/background sub-agent exists in the current tool, run the review synchronously.
- Do **not** claim that a background review is running when it is not.
- Use the same review scope and quality bar as the async mode.

**When review finds issues**
1. Fix the issues silently.
2. Re-run the relevant tests/build.
3. Re-run review if the fix materially changed behavior or touched new files.
4. Present only after the review is clear or residual risk is explicitly called out.

**When review finds no issues**
- State that clearly in the final response.
- Then append the normal verification stamp.

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

This skill governs verification, not authorization. Code is only written when the user explicitly requests it (per `response-protocol` Action Authority). **Exception: code review** — when the user requests a review, the authorization to fix is implicit. Find issues and fix them, don't just report.

Short illustrative snippets (< 10 lines) are explanation-only and do not require build/test execution or verification stamps unless the user asks to verify or execute them.
