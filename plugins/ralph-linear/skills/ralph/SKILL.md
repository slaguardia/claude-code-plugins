---
name: ralph
description: 'Execute one Ralph Wiggum loop iteration. Reads Linear issues, implements next incomplete story, runs quality checks, marks complete. Triggers on: /ralph, ralph iterate, execute story.'
---

# Ralph Execution Skill

Execute ONE iteration of the Ralph Wiggum loop. Implements a single user story from Linear, then exits for fresh context.

---

## Invocation

```
/ralph PD-123
```

Where `PD-123` is the parent Linear issue containing sub-issues (user stories).

---

## The Flow

```
1. FETCH     -> Get parent + sub-issues from Linear
2. CONTEXT   -> Read progress.txt for patterns/learnings
3. SELECT    -> Pick next incomplete story (lowest US-XXX number)
4. IMPLEMENT -> Build it, following acceptance criteria
5. VERIFY    -> Run typecheck, lint, format checks
6. COMMIT    -> Git commit with standardized message
7. UPDATE    -> Mark Linear sub-issue as Done
8. LOG       -> Append learnings to progress.txt
9. EXIT      -> Return control (or signal COMPLETE if all done)
```

---

## Step 1: Fetch from Linear

```
mcp__linear-server__get_issue(id: "[issue-id]")
mcp__linear-server__list_issues(parentId: "[issue-id]")
```

Parse sub-issues to find:

- Story ID (US-XXX from title)
- Status (Done = complete, anything else = incomplete)
- Description and acceptance criteria

---

## Step 2: Load Context

Read `progress.txt` if it exists. Look for:

- **Codebase Patterns** section - reusable conventions
- **Previous iterations** - what was already done, any gotchas

If progress.txt doesn't exist, create it from template.

---

## Step 3: Select Next Story

**Priority order:**

1. Any story currently "In Progress" (resume interrupted work)
2. Lowest-numbered incomplete story (US-001 before US-002)

**If all stories complete:**
Output `<promise>COMPLETE</promise>` and stop.

**Before implementing:**
Mark the selected sub-issue as "In Progress" in Linear.

---

## Step 4: Implement

Read the sub-issue description for:

- User story format (As a... I want... so that...)
- Acceptance criteria (checklist items)

**Rules:**

- Implement ONLY this story, nothing more
- Follow patterns from progress.txt
- Follow codebase conventions from CLAUDE.md
- Make minimal, focused changes
- If you discover needed prerequisite work, STOP and note it

---

## Step 5: Quality Checks

**All must pass before committing:**

```bash
npx tsc --noEmit          # TypeScript (if applicable)
npm run lint              # Linter
npm run format -- --check # Formatter
```

**If checks fail:**

1. Fix the issues
2. Re-run checks
3. Repeat until passing
4. Do NOT commit broken code
5. Do NOT skip or disable checks

---

## Step 6: Commit

**Message format:**

```
feat: [US-XXX] Story title

Brief description of implementation.

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Commands:**

```bash
git add -A
git commit -m "feat: [US-XXX] Story title..."
```

---

## Step 7: Update Linear

Mark sub-issue complete:

```
mcp__linear-server__update_issue(
  id: "[sub-issue-id]",
  state: "Done"
)
```

---

## Step 8: Log Progress

Append to `progress.txt`:

```markdown
---

## Iteration N - [ISO timestamp]

### Story: US-XXX - [Title]

**Linear:** [sub-issue-id] -> Done

**Implemented:**

- [What was built]

**Files changed:**

- `path/to/file.ts` - [what changed]

**Learnings:**

- [Any patterns discovered]
- [Gotchas encountered]
- [Context for future iterations]
```

If you discovered a reusable pattern, add it to the **Codebase Patterns** section at the top.

---

## Step 9: Exit

**If all stories complete:**

1. Mark parent issue as In Review:
   ```
   mcp__linear-server__update_issue(id: "[parent-issue-id]", state: "In Review")
   ```
2. Output:
   ```
   <promise>COMPLETE</promise>
   ```

**If stories remain:**
Exit normally. The bash loop will spawn a fresh instance for the next story.

---

## Handling Problems

### Story is too complex

If you realize mid-implementation the story can't be done atomically:

1. STOP implementing
2. Revert uncommitted changes
3. Add comment to Linear sub-issue explaining the issue
4. Log in progress.txt: "US-XXX needs breakdown"
5. Exit WITHOUT marking complete

### Missing dependency

If the story needs something from a later story:

1. Note the dependency
2. Log in progress.txt
3. Exit WITHOUT marking complete
4. (Human needs to reorder stories in Linear)

### Repeated check failures

If you can't fix failing checks after 3 attempts:

1. Revert: `git checkout -- .`
2. Comment on Linear sub-issue with error details
3. Log in progress.txt
4. Exit WITHOUT marking complete

---

## Output Example

```
Fetching PD-123 from Linear...

Parent: "Allow hosts to message attendees"
Sub-issues:
  [x] PD-124: US-001 - Add schema [Done]
  --> PD-125: US-002 - Create action [Todo] <- SELECTED
  [ ] PD-126: US-003 - Build UI [Todo]

Reading progress.txt... found 1 previous iteration.

Starting iteration 2: US-002 - Create announcement action

Marking PD-125 as In Progress...

Implementing...
[implementation details]

Running quality checks...
  [x] TypeScript: passed
  [x] Lint: passed
  [x] Format: passed

Committing...
  [x] feat: [US-002] Create announcement action

Updating Linear...
  [x] PD-125 -> Done

Updating progress.txt...
  [x] Iteration 2 logged

Stories remaining: 1
Exiting for next iteration.
```
