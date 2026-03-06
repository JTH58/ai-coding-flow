---
name: ddd-bdd-tdd
description: >
  Structured development methodology: Domain-Driven Design → Behavior-Driven Development → Test-Driven Development.
  Trigger this skill when: building a new feature, designing complex business logic, planning API or system architecture, refactoring with new behavior, or creating a new domain/module.
  Also trigger when the user mentions "DDD", "BDD", "TDD", "domain model", "bounded context", "Given-When-Then", "假如-當-那麼", or "scenarios".
  Skip for: simple bug fixes, UI/style tweaks, config changes, one-off scripts, CRUD on existing entities, or static content pages.
---

# DDD → BDD → TDD Methodology

A structured, phase-gated approach for feature development. Each phase must complete and receive user confirmation before proceeding to the next.

## Activation Criteria

| Activate                       | Skip                              |
| ------------------------------ | --------------------------------- |
| New feature development        | Simple bug fix                    |
| Complex business logic         | UI/style tweaks, config changes   |
| API / system design            | One-off scripts, quick prototypes |
| Refactoring with new behavior  | CRUD on existing entities         |
| New domain / module creation   | Static content pages              |

## The Three Phases

| Phase   | Goal              | Output                              |
| ------- | ----------------- | ----------------------------------- |
| **DDD** | Understand domain | Terms, Entities, Rules, Contexts    |
| **BDD** | Define behavior   | Given-When-Then scenarios           |
| **TDD** | Implement safely  | Tested, verified code               |

## Phase Transition Signals

| From → To   | User Signal to Proceed                                                |
| ----------- | --------------------------------------------------------------------- |
| — → DDD     | Request matches activation criteria                                   |
| DDD → BDD   | "OK", "Confirmed", "Continue", "繼續", or equivalent                  |
| BDD → TDD   | "Start coding", "Implement", "Begin TDD", "開始寫", or equivalent     |

## Phase Details

### DDD Phase

Deliverables:

1. **Ubiquitous Language** — Key terms with definitions and contexts
2. **Bounded Contexts** — Context names and responsibilities
3. **Core Entities** — Aggregate roots, key attributes, relationships
4. **Business Rules** — Constraints and invariants
5. **Domain Events** — Key state transitions

Present as a structured summary. End with:

```
📌 DDD Complete — Awaiting Confirmation
```

On user confirmation, write Domain Model to `$AI_BRAIN_ROOT/$PROJECT_NAME/architecture_decisions.md`.

### BDD Phase

Convert DDD output into Given-When-Then scenarios using Traditional Chinese Gherkin:

- **假如** (Given) — preconditions
- **當** (When) — action
- **那麼** (Then) — expected outcome
- **而且** (And) — additional conditions

Cover: happy path, edge cases, error cases, boundary conditions. End with:

```
📌 BDD Complete — Awaiting Confirmation
```

On user confirmation, write each scenario as a task in `$AI_BRAIN_ROOT/$PROJECT_NAME/todo.md`.

### TDD Phase

Activated only when user explicitly requests code.

Before writing the first test:

0. **Learn from codebase** — Find 2+ similar implementations in the existing project. Study their patterns: file structure, naming, libraries, error handling. Use the same utilities and abstractions — do not reinvent what already exists. If no similar code exists, inform the user this is a new pattern.

Follow the Red-Green-Refactor cycle:

1. **Red** — Write a failing test derived from a BDD scenario
2. **Green** — Write minimal code to pass the test
3. **Refactor** — Clean up while keeping tests green

Hand off to `code-verification` skill for the build/test loop and final stamp.

## AI-Brain Write-Back

Path: derive `$AI_BRAIN_ROOT` per ai-brain Paths section.

## Key Rules

| Rule                  | Description                                                 |
| --------------------- | ----------------------------------------------------------- |
| **No Skipping**       | Complete each phase before proceeding                       |
| **User Confirmation** | DDD & BDD require explicit approval before the next phase   |
| **Test First**        | In TDD, always write the failing test before implementation |
| **AI-Brain Sync**     | On phase confirmation, persist results to AI-Brain          |
