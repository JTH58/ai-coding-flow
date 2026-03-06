---
name: tech-defaults
description: >
  Default tech stack, language/framework preferences, and technology selection guidance.
  Trigger this skill when: the user starts a new project without specifying a stack,
  asks for technology recommendations, discusses deployment or infrastructure choices,
  or when code generation needs a default language/framework. Also trigger when the user
  mentions "tech stack", "技術選型", "what framework", or "which language". Skip for:
  conversations that already have an established stack (defer to ai-brain's architecture
  decisions), or non-technical discussions.
---

# Tech Defaults

## Default Stack

When the user does not specify a technology, use these defaults:

| Domain     | Default                |
| ---------- | ---------------------- |
| Server     | Ubuntu                 |
| Frontend   | Next.js + `.tsx`       |
| Backend    | Node.js                |
| Mobile     | Kotlin (Android)       |

These defaults are overridden by:
1. **AI-Brain constraints** — If `architecture_decisions.md` specifies a stack, use that instead. AI-Brain always wins.
2. **User's explicit choice** — If the user names a technology in the current conversation, follow their preference.

## When to Apply

- **New project, no stack mentioned** → Suggest defaults, confirm with user before proceeding.
- **Existing project** → Read from AI-Brain or project files (`package.json`, `build.gradle`, etc.). Never assume defaults for existing projects.
- **Technology comparison** → Present trade-offs objectively. Recommend based on the user's specific context, not just defaults.

## Selection Principles

When recommending technology:

1. **Context over convention** — The best tool depends on the project's constraints, not general popularity.
2. **Ecosystem fit** — Prefer tools that integrate well with the user's existing stack.
3. **Simplicity bias** — When two options are roughly equivalent, recommend the simpler one.
4. **Production readiness** — For production systems, prefer battle-tested tools over cutting-edge ones. For prototypes, lean toward developer experience.
