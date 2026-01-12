# Ralph Iteration Prompt

You are executing one iteration of the Ralph Wiggum loop. Your job is to implement ONE user story from Linear, then exit.

## Context

- **Linear Issue ID:** {{LINEAR_ISSUE_ID}}
- **Memory persists through:** Linear state, git commits, progress.txt
- **This iteration:** Fresh context - read progress.txt for previous learnings

---

## Your Task

### 1. Fetch Current State

Use the Linear MCP tools:

```
mcp__linear-server__get_issue(id: "{{LINEAR_ISSUE_ID}}")
mcp__linear-server__list_issues(parentId: "{{LINEAR_ISSUE_ID}}")
```

### 2. Read progress.txt

Check for:

- Codebase patterns (reuse them)
- Previous iteration learnings
- Any noted blockers or gotchas

### 3. Select Next Story

From the sub-issues:

- Find stories NOT in "Done" state
- Pick the lowest US-XXX number
- If ALL stories are Done, output `<promise>COMPLETE</promise>` and stop

### 4. Mark In Progress

```
mcp__linear-server__update_issue(id: "[sub-issue-id]", state: "In Progress")
```

### 5. Implement

Read the sub-issue description for:

- User story (As a... I want... so that...)
- Acceptance criteria

**Rules:**

- ONE story only
- Follow existing patterns
- Make minimal changes
- If story is too complex, STOP and note it

### 6. Quality Checks

**All must pass:**

```bash
npx tsc --noEmit
npm run lint
npm run format -- --check
```

Fix any failures. Do NOT commit broken code.

### 7. Commit

```bash
git add -A
git commit -m "feat: [US-XXX] Story title

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 8. Mark Complete in Linear

```
mcp__linear-server__update_issue(id: "[sub-issue-id]", state: "Done")
```

### 9. Update progress.txt

Append iteration log with:

- Story completed
- Files changed
- Learnings discovered

### 10. Check Completion

Re-check if all stories are Done:

- If YES:
  - Mark parent issue as In Review: `mcp__linear-server__update_issue(id: "{{LINEAR_ISSUE_ID}}", state: "In Review")`
  - Output `<promise>COMPLETE</promise>`
- If NO: exit normally

---

## Important

- **ONE story per iteration** - Never do more
- **Quality gates are mandatory** - No broken commits
- **Update progress.txt** - Future iterations depend on it
- **Exit cleanly** - The loop handles next iteration

---

## Completion Signal

When ALL stories are complete, output exactly:

```
<promise>COMPLETE</promise>
```

This tells the loop to stop.
