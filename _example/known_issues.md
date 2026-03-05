# Known Issues & Technical Debt

## Active Bugs

### [BUG-001] SSR hydration mismatch on /dashboard
**Date:** 2025-02-01
**Severity:** Medium
**Symptom:** Console warning `Text content does not match server-rendered HTML` on dashboard page.
**Root Cause:** `useLocalStorage` hook renders differently on server vs client.
**Workaround:** Wrap dynamic content in `<ClientOnly>` component.
**Status:** Open — need to refactor to use `useSyncExternalStore`.

### [BUG-002] Prisma connection pool exhaustion under load
**Date:** 2025-02-05
**Severity:** High
**Symptom:** `PrismaClientKnownRequestError: Too many database connections` after ~50 concurrent users.
**Root Cause:** Each API route creates a new PrismaClient instance in development.
**Fix Applied:** Singleton pattern via `globalThis.__prisma`.
**Status:** Fixed in dev — needs load testing in staging.

## Technical Debt

### [DEBT-001] No input validation on API routes
**Date:** 2025-01-20
**Impact:** Low (internal use only for now)
**Plan:** Add Zod schemas before public launch.

### [DEBT-002] Test coverage below 40%
**Date:** 2025-01-25
**Impact:** Medium — risky for refactoring
**Plan:** Prioritize tests for auth and workspace core logic.
