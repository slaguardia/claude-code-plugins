# Claude Docs Plugin

Tools for managing CLAUDE.md documentation files that provide context to Claude Code.

## Commands

### `/capture-learnings` - Session Knowledge Capture

Captures insights discovered during a development session into documentation.

**Use when:** You've just solved a tricky problem, discovered a gotcha, or found a pattern worth remembering.

**What it captures:**
- Gotchas (API quirks, config nuances, edge cases)
- Fixes (non-obvious solutions)
- Patterns (what works, what doesn't)
- Dependency issues (peer deps, version constraints)

**Output:** Targeted updates to specific doc sections based on what was learned.

---

### `/update-docs` - Structural Documentation Sync

Syncs all documentation with the current codebase structure.

**Use when:** You've made structural changes (added routes, changed dependencies, reorganized directories) and docs are now stale.

**What it updates:**
- Directory structure
- Dependencies and versions
- Routes/pages
- Tech stack changes
- CHANGELOG entries

**Output:** Comprehensive sweep of all doc files to match current code reality.

---

## When to Use Which

| Situation | Command |
|-----------|---------|
| Just fixed a weird bug | `/capture-learnings` |
| Discovered a library quirk | `/capture-learnings` |
| Added new routes/pages | `/update-docs` |
| Changed dependencies | `/update-docs` |
| Refactored directory structure | `/update-docs` |
| Found a useful pattern | `/capture-learnings` |
