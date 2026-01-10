---
description: Capture learnings from a Claude session into project documentation
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion
---

Capture insights, discoveries, and learnings from the current Claude session into project documentation.

## Context

Unlike `/update-docs` which does a comprehensive documentation sweep, this command is for **targeted updates** based on specific things learned during a development session.

This is useful for:
- Gotchas or quirks discovered (API behavior, config nuances)
- Patterns that work well (or don't)
- Fixes for non-obvious issues
- Clarifications about how things actually work
- Dependencies that have hidden requirements

---

## Instructions

### 1. Identify Learnings

First, review the conversation history to identify learnings worth documenting. Look for:

- **Gotchas**: Surprising behavior, edge cases, or "watch out for this"
- **Fixes**: Solutions to problems that weren't obvious
- **Patterns**: Approaches that worked well (or anti-patterns to avoid)
- **Clarifications**: How something actually works vs. how it appears to work
- **Dependencies**: Hidden requirements, peer deps, version constraints

If the learnings aren't clear from context, ask the user:

> What did we discover in this session that should be documented?

### 2. Categorize and Route

Determine where each learning belongs:

| Type | Destination |
|------|-------------|
| Implementation patterns, coding conventions | `CLAUDE.md` |
| Dependency gotchas, version constraints | `docs/TECH_STACK.md` |
| Data flow, architectural decisions | `docs/ARCHITECTURE.md` |
| Bug fixes, behavioral changes | `docs/CHANGELOG.md` |
| Product decisions, scope clarifications | `docs/PRODUCT.md` |

### 3. Make Targeted Updates

For each learning:

1. Read the target file
2. Find the appropriate section (or create one if needed)
3. Add the learning concisely
4. Preserve existing content and structure

**Writing style:**
- Be specific and actionable
- Include context for why this matters
- Use examples where helpful
- Keep it brief - one learning per bullet/section

### 4. Update CHANGELOG

If the learnings resulted from actual code changes, add an entry to `docs/CHANGELOG.md` under `[Unreleased]`.

If it's purely documentation/knowledge, skip CHANGELOG.

---

## Example Learnings

**Gotcha example (for TECH_STACK.md):**
> `react-native-reanimated` requires the babel plugin in `babel.config.js` - without it, animations silently fail on Android.

**Pattern example (for CLAUDE.md):**
> Use `useCallback` for navigation handlers to prevent re-renders when passing to child components.

**Fix example (for CHANGELOG.md):**
> Fixed keyboard covering input by adding `KeyboardAvoidingView` with `behavior="padding"` on iOS.

---

## Output

Summarize what was added and where:

```
Updated CLAUDE.md:
- Added note about useCallback for navigation handlers

Updated docs/TECH_STACK.md:
- Added reanimated babel plugin requirement to Known Issues

No CHANGELOG update (documentation only)
```
