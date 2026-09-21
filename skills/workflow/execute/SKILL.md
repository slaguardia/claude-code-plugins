---
name: execute
description: 'Autonomously implement an entire feature from a parent task spec (Linear issue, local file, or conversation), one sub-task at a time, with strict per-issue discipline: AC-as-checklist, hard scope boundaries, observable verification before marking done. Triggers on: /execute, execute issue, implement issue, implement feature, build feature, work the issue.'
---

# Execute Skill

Autonomously implement a feature end-to-end, one sub-task at a time, with strict per-issue discipline. Runs in the current conversation — no headless loop, no bash respawn.

**The problem this solves:** Detailed plans get implemented in a single sweeping pass that confuses "I touched the relevant code" with "I satisfied every acceptance criterion." Things get missed. This skill enforces the discipline that planning alone cannot.

**Companion to** `/interactive-planning`: planning produces well-structured parent + sub-issues; `/execute` works through them with the rigor the plan deserves.

---

## The Two Loops

```
OUTER LOOP (autonomous):
  Walk sub-tasks in dependency order.
  For each → run INNER LOOP.
  Stop only when all done OR a defined pause-point is hit.

INNER LOOP (disciplined, per sub-task):
  1. READ AC       → Full sub-task description, every bullet
  2. CHECKLIST     → AC bullets → TodoWrite items, 1:1
  3. MARK STARTED  → Update task source (Linear → "In Progress")
  4. IMPLEMENT     → Only this sub-task's scope
  5. VERIFY EACH   → Each AC bullet, with observable evidence
  6. QUALITY GATE  → Project's lint/typecheck/test commands
  7. COMMIT        → One commit per sub-task
  8. MARK DONE     → Linear → "In Review" (user does final approval)
  9. NEXT          → Outer loop picks next sub-task
```

---

## Invocation

| Form | Behavior |
|---|---|
| `/execute PLA-468` | Fetch parent + sub-issues from Linear via MCP |
| `/execute path/to/spec.md` | Read local file; treat unchecked checkboxes as tasks |
| `/execute` | Use current conversation context (must contain a clear task spec) |

If the parent has sub-tasks → work through them in order.
If the parent has none → treat the parent itself as the single task.

---

## Step 1: Resolve and Load the Source

### Linear (when arg looks like an issue ID)
```
mcp__linear-server__get_issue(id: "PLA-468")
mcp__linear-server__list_issues(parentId: "<parent-id>")
```
- Sort sub-issues by US-XXX number ascending
- Treat status of "Done" or "In Review" as complete; everything else is incomplete
- Note any inter-sub-issue dependencies referenced in AC

### Local file (when arg is a path)
- Read the file
- Find unchecked checkboxes (`- [ ]`) — each is a task
- Group by H2 headers if present; treat each H2 group as a sub-task

### Current conversation (no arg)
- The conversation must already contain a structured task spec
- If unclear, STOP and ask the user for a Linear issue ID or file path. Do not guess.

---

## Step 2: Project Adaptation (read first, every time)

Before touching code, read these to learn the project's conventions:

1. **`CLAUDE.md`** at repo root (and any nested `**/CLAUDE.md`) — domain conventions, file paths, naming rules
2. **`package.json`** scripts — find the actual `lint`, `typecheck`, `format`, `test` commands (do NOT assume `npm run lint` exists)
3. **Recent `git log`** — match commit message style (subject line conventions, trailers, scope prefixes)

If `CLAUDE.md` defines specific patterns (where hooks go, how naming works, what to import from where), follow them exactly. Do not impose generic conventions.

---

## Step 3: Outer Loop — Iterate Sub-Tasks

For each incomplete sub-task, in dependency order:

1. Run the **Inner Loop** (steps 4–11)
2. If inner loop succeeds → continue to next sub-task
3. If inner loop hits a **pause point** → ask user, wait for response, then continue
4. If inner loop hits a **blocker** → mark sub-task blocked, skip to next non-dependent sibling
5. After all sub-tasks done → mark parent "In Review", produce final report

**Hard rule (non-negotiable):** Never bundle work across sub-tasks. Even if "while I'm here it's easy," DO NOT touch siblings. Note out-of-scope discoveries for the final report.

---

## Step 4: Read Full AC for Current Sub-Task

Read the entire sub-task description. Extract:
- The user story (As a / I want / so that) — for context
- Every AC bullet — these become the checklist
- Any "Out of Scope" notes — these are forbidden zones
- Any dependencies on prior sub-tasks — verify they're done before proceeding

---

## Step 5: AC → TodoWrite Checklist (1:1)

Create one TodoWrite item per AC bullet. Do **not** collapse multiple AC into one todo — that's already cheating on verification.

Example. AC says:
- [ ] Add `survey_responses` table with FK to `auth.users(id)`
- [ ] Survey responses are write-once (no updates allowed)
- [ ] [UI] Modal shows in feed when survey is active

TodoWrite (within this sub-task):
1. Add survey_responses table with FK to auth.users(id)
2. Enforce write-once via DB trigger or RLS
3. Modal shows in feed when survey is active

---

## Step 6: Mark Source as In Progress

**Linear:**
```
mcp__linear-server__update_issue(id: "<sub-issue-id>", state: "In Progress")
```

**Local file:** No state change needed; the checkbox stays unchecked until verified done.

---

## Step 7: Implement (Scope Discipline)

**The single-issue rule:** Implement ONLY what this sub-task's AC requires.

When you notice something outside scope:
| Discovery | Action |
|---|---|
| Bug elsewhere in the codebase | Note for final report; do NOT fix |
| Missing prereq from a not-yet-done sibling | STOP — see "Pause Points" |
| Tangentially-related cleanup opportunity | Note for final report; do NOT do |
| "This would be cleaner if I refactored X…" | No. The current AC doesn't ask for it |
| Half-finished work the AC doesn't mention | Note; do NOT extend |

Follow project conventions you read in Step 2. If `CLAUDE.md` specifies patterns, match them exactly.

---

## Step 8: Verify Each AC With Observable Evidence

**Before marking any todo complete, you must state observable evidence.** Not "I edited the file" — actual evidence the AC is satisfied.

| AC type | Required evidence |
|---|---|
| Code addition | File path + what's there (cite the function/import/export) |
| DB schema change | Migration filename + the SQL that creates/alters the structure |
| RPC / function | Function exists, callable, with signature matching AC |
| UI behavior | Run the app/dev server, navigate, describe what you see — OR explicitly: "Cannot verify UI without device — flagging for user verification" |
| Negative AC ("should NOT do X") | Describe the constraint mechanism (validation, RLS, type guard) |
| Performance / non-functional | Reproducible measurement OR explicit "cannot verify in this environment" |

If you cannot produce observable evidence, **the AC is not done**. Either keep working on it or hit the pause point.

---

## Step 9: Quality Gate

Run the project's checks (commands found in Step 2):

```
typecheck (e.g., npx tsc --noEmit)
lint      (e.g., npm run lint)
format    (e.g., npm run format -- --check)
test      (if the project has a test framework AND tests exist for this area)
```

**Failure handling:**
| Failure | Action |
|---|---|
| Type/lint error in code I wrote | Fix it. Re-run. |
| Format issue | Run the formatter. Re-run check. |
| Type/lint error in code I did NOT touch | PAUSE — ask user before papering over |
| Test failure I introduced | Fix the code (NOT the test) |
| Test failure in unrelated area | PAUSE — ask user |
| 3 attempts on the same error → still failing | PAUSE — ask user |

**Never:** skip checks, disable rules, add `@ts-ignore`, use `--no-verify`, comment out failing tests.

---

## Step 10: Commit (One Per Sub-Task)

Stage **specific files** (not `git add -A` — sweeping in unrelated work violates scope discipline).

Match the project's commit message style (read recent `git log` from Step 2). Common pattern:

```
<type>: [US-XXX] <Story title>

<Brief description of what was implemented and why.>

Co-Authored-By: Claude <noreply@anthropic.com>
```

Use a HEREDOC for the message to preserve formatting. Do NOT use `--amend`. Do NOT use `--no-verify`.

---

## Step 11: Mark Source Done

**Linear:**
```
mcp__linear-server__update_issue(id: "<sub-issue-id>", state: "In Review")
```

**Stories go to "In Review", not "Done".** The user reviews the diff and decides whether to mark Done.

**Local file:** Check the box for this task (`- [ ]` → `- [x]`).

---

## Pause Points (Stop and Ask the User)

The skill autonomously continues through sub-tasks **EXCEPT** at these well-defined moments:

1. **AC is genuinely ambiguous** — could be implemented in multiple materially different ways. Ask. Don't guess.
2. **Quality check fails non-obviously** — error in code you didn't touch, broken test infra, dependency mismatch. Ask. Don't paper over.
3. **AC requires manual verification you can't do** — UI behavior on a real device, third-party integration response, performance under real load. State this clearly and ask the user to verify before continuing.
4. **Sub-task prereq isn't done** — e.g., US-003 needs migration that US-002 was supposed to write but didn't. Skip US-003, continue with non-dependent siblings, surface in final report.
5. **Risky/destructive action** — drop table, force push, delete user data, modify production config. Always ask, even in auto mode.

In all other cases: keep going. Pause-points are for genuine human-judgment moments, not "I'm slightly unsure."

---

## Final Report

When the outer loop completes (or pauses for user input), report in this shape:

```
## Execute summary for <PARENT-ID>

Completed: N sub-tasks → all "In Review"
  ✓ US-001 — <Title>     [<commit-sha>]
  ✓ US-002 — <Title>     [<commit-sha>]
  ...

Blocked: M sub-tasks
  ⚠ US-006 — <Title>
    Reason: <specific blocker>
    Suggested fix: <what would unblock>

Out-of-scope items noted (NOT implemented):
  • <File>:<line> — <description>
  • <description>

Quality: typecheck ✓ lint ✓ format ✓ test ✓
Commits: N (one per sub-task)
Parent issue: <PARENT-ID> → In Review

Manual verification needed (could not test autonomously):
  • <AC requiring device/external check>
```

---

## Anti-Patterns This Skill Explicitly Blocks

| Anti-pattern | What it produces | What this skill does instead |
|---|---|---|
| "Implement all sub-issues at once" | Things missed in the sweep | One sub-task at a time, isolated commits |
| "Mark done because the code compiles" | AC bullets silently unsatisfied | Each AC verified with observable evidence |
| "While I'm here, let me also fix…" | Scope creep, broken bisects | Note for final report, don't fix |
| "Skip quality checks because change is small" | Tech debt accumulates | Always run, always pass, never skip |
| "Mark Done autonomously" | User loses review checkpoint | Always "In Review" — user does final approval |
| "Bundle multiple sub-issues into one commit" | Hard to revert, hard to review | One commit per sub-task, ever |
| "Use git add -A to stage everything" | Sweeps in unrelated changes | Stage specific files for this sub-task only |
| "Add @ts-ignore to make the check pass" | Hides real type errors | Fix the type, or pause and ask |

---

## Related Skills

- **`interactive-planning`** — Creates the parent + sub-issues that `/execute` consumes
- **`research-planning`** — Like `interactive-planning` but with web/codebase research first
- **`headless-planning`** — Async planning via Linear inline questions
- **`ralph`** — Bash-loop variant that respawns Claude per iteration (lower fidelity, runs unattended)
- **`simplify`** — Run after `/execute` finishes for a polish/cleanup pass

---

## Pre-Flight Checklist (mental, before declaring outer loop done)

- [ ] Read `CLAUDE.md` and project conventions before starting
- [ ] Found the actual lint/typecheck/test commands (didn't assume)
- [ ] Each sub-task got its own AC-as-TodoWrite checklist
- [ ] Each AC bullet verified with observable evidence (not just "code edited")
- [ ] One commit per sub-task, message matches project style
- [ ] Quality gate passed for every commit (no skipped checks)
- [ ] All sub-tasks either "In Review" or explicitly marked blocked with reason
- [ ] Parent issue moved to "In Review"
- [ ] Out-of-scope items surfaced in final report (not silently fixed, not silently ignored)
- [ ] No `@ts-ignore`, no `--no-verify`, no commented-out tests
- [ ] Manual-verification AC items called out for the user
