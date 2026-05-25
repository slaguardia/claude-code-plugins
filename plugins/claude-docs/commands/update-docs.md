---
description: Detect and clean up stale documentation, then document new patterns from recent code changes
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

## **Goal**

Detect and clean up stale documentation, then document any new patterns from recent code changes. This is the single command for keeping project documentation accurate and current.

---

## **Usage**

Run after making code changes that could affect documentation, or periodically to audit doc freshness.

**Example invocations:**

- `/update-docs` — Default mode: check docs against staged + unstaged git changes
- `/update-docs --full` — Full audit: scan ALL docs for references to code that no longer exists
- `/update-docs <free-text hint about what changed>` — Default mode + hint about what changed (e.g. "notification system refactored to use batched delivery")

---

## **Procedure**

### Phase 1: Gather Context

#### Step 1.1: Determine Mode

- If the user passed `--full`, use **Full Audit Mode** (Step 1.3)
- Otherwise, use **Git Diff Mode** (Step 1.2)

#### Step 1.2: Git Diff Mode (Default)

Collect the set of changed files and their nature:

```bash
# Staged + unstaged changes (file paths and status)
git diff --name-status HEAD

# Also check for untracked files that might be new additions
git status --short
```

From this output, build three lists:

- **Deleted files**: Files that were removed (status `D`)
- **Renamed files**: Files that were moved/renamed (status `R`)
- **Modified files**: Files that were changed (status `M`)
- **Added files**: New files (status `A` or `??`)

For modified files, also capture what changed:

```bash
# Get the diff content to understand what was modified
git diff HEAD -- <file>
```

Pay attention to:

- Renamed/removed exports (functions, hooks, components, types)
- Changed function signatures
- Moved or renamed query keys
- Changed import paths

**Skip to Phase 2** after collecting changes.

#### Step 1.3: Full Audit Mode (`--full`)

Scan ALL documentation files for code references, then verify each reference exists.

**1.3a: Collect all doc files:**

- All `**/CLAUDE.md` files
- All `docs/**/*.md` files

Exclude any vendored/`node_modules/` paths and any project-specific noise directories (e.g., generated SDKs, build artifacts).

**1.3b: Extract references from each doc file.** Look for:

| Reference Type            | Pattern to Extract                                            |
| ------------------------- | ------------------------------------------------------------- |
| File paths                | Backtick-wrapped paths ending in `.ts`, `.tsx`, `.sql`, `.js` |
| File paths in tables      | Pipe-delimited table cells containing file paths              |
| Component/file references | References like `EventDetailScreen.tsx` without full paths    |
| Import paths              | `from '@/...'` or `from '...'` patterns inside code blocks    |
| Hook names                | `use[A-Z][a-zA-Z]+` patterns referenced as callable           |
| Function names            | Named exports or function calls in "Reference" sections       |

**1.3c: Verify each reference exists:**

1. Check if the file exists at the stated path
2. For partial paths (e.g., `EventDetailScreen.tsx`), search the codebase for a matching file
3. For function/hook/component names, search for their definition in the codebase

Build a list of **broken references** (file not found, function not defined, etc.).

**Continue to Phase 2.**

---

### Phase 2: Identify Stale Documentation

#### Step 2.1: Scan Documentation Files

Discover ALL documentation files in the repo:

```bash
# Every CLAUDE.md in the tree (skip vendored dirs)
find . -name CLAUDE.md -not -path '*/node_modules/*' -not -path '*/.git/*'

# Every doc under docs/
find docs -type f \( -name '*.md' -o -name '*.mdx' \) 2>/dev/null
```

Build a working set of `(path, purpose)` pairs by reading the first heading/intro of each file. Do not assume any specific layout — projects differ. Common patterns to expect:

- A root `CLAUDE.md` with overall project orientation
- Nested `CLAUDE.md` files in major source directories (e.g. `src/<area>/CLAUDE.md`)
- A `docs/` tree with topic-organized detail docs and often a `docs/README.md` index

#### Step 2.2: Cross-Reference Changes Against Docs

For each documentation file, classify stale content:

**DEFINITELY STALE (auto-fix):**

1. **Deleted file references** — Doc references a file that no longer exists
2. **Renamed file references** — Doc uses old name/path for a renamed file
3. **Removed exports** — Doc references a function, hook, or component that was removed
4. **Dead import paths** — Code example shows an import that no longer resolves

**PROBABLY STALE (verify before changing):**

5. **Changed function signatures** — Doc shows a signature that no longer matches the implementation
6. **Outdated code examples** — Code block demonstrates a replaced pattern
7. **Stale line number references** — Line numbers no longer correspond to referenced code
8. **Changed query key patterns** — Query keys that have been renamed

**SAFE TO KEEP (do not remove):**

9. **Pattern descriptions** — High-level pattern explanations valid regardless of reference file
10. **Architecture overviews** — System design docs describing overall approach
11. **Historical context** — Sections explaining "why" a decision was made
12. **Stable-by-design paths** — Directories the project treats as conventionally stable (e.g. migration repeatable folders, generated SDK roots). Confirm by checking project conventions before flagging.
13. **Cross-doc references** — Links between docs (only remove if target doc was deleted)

---

### Phase 3: Clean Up Stale Documentation

#### Step 3.1: Fix DEFINITELY STALE Items

- **Deleted file references**: Remove the reference line, or replace with the correct file if functionality moved. If the entire section is about a deleted feature, remove the section.
- **Renamed file references**: Update the path to the new location.
- **Removed exports**: Remove the reference. If replaced, update to the replacement.
- **Dead import paths**: Update the import path in the code example.

#### Step 3.2: Verify and Fix PROBABLY STALE Items

For each probably stale item, read the CURRENT source code to determine the correct state:

- **Changed signatures**: Read the current function/hook and update the documented signature.
- **Outdated code examples**: Read the current implementation and update to match.
- **Stale line numbers**: Update to correct line numbers or remove them entirely (they drift frequently; prefer function/section names instead).
- **Changed query keys**: Update to the current key pattern.

#### Step 3.3: Clean Up Empty Sections

After removing stale references, check if any section has become empty (heading with no content). Remove empty sections cleanly.

#### Step 3.4: Safety Check

Before finalizing any removal, verify:

1. The pattern or concept described is truly obsolete (not just the reference file)
2. No other part of the codebase still uses the documented pattern
3. Removing the content would not leave a gap in documentation coverage

**When in doubt, update the reference rather than remove the section.**

---

### Phase 4: Document New Patterns

#### Step 4.1: Identify Documentation Gaps

From the code changes gathered in Phase 1, identify:

- **New files/features** that have no documentation anywhere
- **New patterns** introduced by the changes (new hooks, components, SQL functions)
- **Changed behavior** that existing docs should mention but don't
- **New gotchas or edge cases** discovered during the changes

#### Step 4.2: Choose Documentation Location

Use the documentation map discovered in **Step 2.1** to decide where new content belongs. Match the new pattern to the most specific existing doc whose scope covers it. If no existing doc fits, create a new one in the conventional location for the project.

**Placement rules:**

- **CLAUDE.md (per directory)**: Concise patterns needed during coding in that area (the "what to do"). Place at the closest ancestor directory that owns the pattern.
- **docs/ (or equivalent)**: Detailed explanations and architectural context (the "why"). Use the topic folder closest in scope; create a new one only if no existing topic fits.
- Often document in BOTH: quick reference in the nearest `CLAUDE.md`, details in a topic doc.
- If the project has neither a `docs/` tree nor nested `CLAUDE.md` files, default to extending the root `CLAUDE.md` and only introduce new files when content grows too large for it.

#### Step 4.3: Write New Documentation

**For CLAUDE.md sections:**

````markdown
## [Pattern Name]

### Problem

[Brief description of when this issue occurs]

### Solution

[Explanation of the fix/pattern]

```typescript
// Code example
```

### Reference

- `path/to/file.tsx` - [brief description]
````

**For docs/ files:**

```markdown
# [Topic Title]

## Overview

[What this document covers and why it matters]

## Problem

[Detailed explanation of the issue]

## Solution

[In-depth explanation with rationale]

## Implementation

[Details with code examples]

## Examples

- `path/to/file.tsx` - [description]

## Related

- [Link to related docs]
```

#### Step 4.4: Update doc index

If the project has a `docs/README.md` (or equivalent index file) and you created new docs, add entries under the appropriate section so the new files are discoverable.

---

### Phase 5: Summary Report

After all changes are complete, output a summary:

```
## Documentation Update Summary

### Stale Content Cleaned Up
| File | Section | Action |
|---|---|---|
| src/screens/CLAUDE.md | Reference Implementations | Updated path: `OldFile.tsx` → `NewFile.tsx` |
| docs/performance/... | Code Example | Updated function signature to match current impl |

### New Documentation Added
| File | Section | Description |
|---|---|---|
| src/hooks/CLAUDE.md | Batch Delivery Pattern | Documented new batched notification hook |

### No Changes Needed
[List any docs that were checked but found to be current]
```

---

## **Reference Type Checklist**

When scanning for staleness, check each doc for these reference types:

- [ ] File paths in backticks (`` `src/path/to/file.ts` ``)
- [ ] File names in table cells (pipe-delimited)
- [ ] File names in "Reference" or "Reference Implementations" sections
- [ ] Import statements in code blocks (`from '@/...'`)
- [ ] Hook names (`use[Name]`)
- [ ] Function names in "Key Actions" or "Available Functions" sections
- [ ] Component names in "Components" tables
- [ ] Query key arrays (`['key-name', ...]`)
- [ ] Line number references (`file.tsx:123-456`)
- [ ] Cross-references to other docs (`See docs/...`, `See src/.../CLAUDE.md`)
- [ ] Language/framework-specific identifiers used by the project (e.g. SQL function names like `R__function_name.sql` / `public.function_name()` for Flyway+Postgres, Rails model names, RPC handler names — adapt to the stack)

---

## **Notes**

- **Do not duplicate information** already documented elsewhere. Check before adding.
- **Update existing sections** when content needs refinement rather than adding duplicates.
- **Keep CLAUDE.md practical and concise** — focus on "what to do" not "what happened."
- **Use docs/ for "why" explanations** and architectural context.
- **Preserve historical context** (e.g., root cause analyses, version-specific notes) unless the entire feature was removed.
- **Line number references** are fragile. Prefer function/section names instead.
- **When in doubt, update rather than delete.** Better to fix a stale reference than remove a useful pattern.
- **Exclude vendored and generated paths** from all scanning (e.g. `node_modules/`, build outputs, generated SDK directories).
