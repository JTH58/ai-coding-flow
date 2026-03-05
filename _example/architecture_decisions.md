# Architecture Decision Log

## Hard Constraints
* **Language:** TypeScript (strict mode)
* **Framework:** Next.js 15 (App Router)
* **State Management:** Zustand
* **Naming Convention:** camelCase for variables, PascalCase for components
* **Directory Structure:** Feature-based (`src/features/<name>/`)

## Domain Model
> Updated when DDD methodology is used.

### Ubiquitous Language
| Term | Definition | Context |
|------|------------|---------|
| Workspace | A user's isolated project environment | Core domain |
| Blueprint | A reusable project template | Template system |
| Snapshot | A point-in-time backup of workspace state | Backup system |

### Bounded Contexts
* Auth Context — User registration, login, session management
* Workspace Context — CRUD and collaboration on workspaces
* Template Context — Blueprint management and instantiation

### Core Entities
* User (Aggregate Root) — email, displayName, role
* Workspace (Aggregate Root) — name, ownerId, members[], status
* Blueprint (Aggregate Root) — name, schema, version

## Decision History
### [ADR-001] 2025-01-15 Use Next.js App Router over Pages Router
* **Context:** Starting new project, need SSR + API routes
* **Decision:** App Router for better layouts, server components, and streaming
* **Consequences:** Team needs to learn RSC patterns; some libraries not yet compatible

### [ADR-002] 2025-01-20 Choose Zustand over Redux
* **Context:** Need lightweight state management for client-side state
* **Decision:** Zustand for simplicity and minimal boilerplate
* **Consequences:** Less ecosystem tooling than Redux, but faster development velocity
