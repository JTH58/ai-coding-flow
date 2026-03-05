# Development Journal

## 2025-02-05
- Fixed Prisma connection pool issue (see known_issues.md BUG-002)
- Decided to use singleton pattern — this seems to be a common Next.js + Prisma gotcha
- Need to write a troubleshooting entry in Common Brain for this

## 2025-02-01
- Encountered SSR hydration mismatch on dashboard
- Spent 2 hours debugging — turned out to be `useLocalStorage` rendering `null` on server
- Temporary fix with `<ClientOnly>`, but should use `useSyncExternalStore` properly

## 2025-01-20
- Evaluated Redux vs Zustand vs Jotai for state management
- Zustand won: smallest bundle, simplest API, good TypeScript support
- Recorded as ADR-002

## 2025-01-15
- Project kickoff! Chose Next.js 15 App Router
- Set up Prisma with PostgreSQL
- Basic folder structure: `src/features/`, `src/components/`, `src/lib/`
- First ADR recorded
