# Common AI-Brain Schema Reference
> Read this file when initializing or writing to Common AI-Brain.

---

## `_catalog.json` Structure

```json
{
  "version": "1.0.0",
  "lastUpdated": "2026-02-12",
  "categories": [
    {
      "id": "preferences",
      "name": "Personal Preferences",
      "file": "preferences.md",
      "keywords": ["preference", "style", "format", "naming", "convention"],
      "aliases": ["habit", "standard", "rule"],
      "weight": 3,
      "hitCount": 0,
      "lastAccessed": null,
      "entryCount": 0,
      "_embedding": null
    }
  ]
}
```

## Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique category identifier |
| `name` | string | Display name |
| `file` | string | Corresponding Markdown content file |
| `keywords` | string[] | Exact-match keywords |
| `aliases` | string[] | Semantic synonyms for AI soft-matching |
| `weight` | number (1-5) | Load priority. 5 = highest, 3 = default, 1 = low-frequency |
| `hitCount` | number | Cumulative load count, auto-increment on each load |
| `lastAccessed` | string\|null | Last loaded date (YYYY-MM-DD) |
| `entryCount` | number | Number of entries in this category |
| `_embedding` | null | Reserved for future MCP vector tool integration |

---

## Entry Format (for writing to .md files)

```markdown
## [Short Title]
**Date:** YYYY-MM-DD
**Context:** One-line description of the use case
**Best Practice:**
- Key point 1
- Key point 2
**Keywords:** keyword1, keyword2
```

---

## Default Categories

| id | name | file | Default weight |
|----|------|------|---------------|
| `preferences` | Personal Preferences | `preferences.md` | 3 |
| `troubleshooting` | Cross-Project Troubleshooting | `troubleshooting.md` | 3 |
| `toolchain` | Toolchain Experience | `toolchain.md` | 3 |
